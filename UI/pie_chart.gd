@tool
class_name PieChart
extends Control

signal slice_hovered(slice: PieSlice, index: int)
signal slice_unhovered
signal slice_clicked(slice: PieSlice, index: int)
signal slice_content_spawned(node: Node, key: int, slice: PieSlice, index: int)

enum LegendPosition { NONE, RIGHT, LEFT, TOP, BOTTOM }

@export_group("Data")
@export var slices: Array[PieSlice] = []:
	set = _set_slices
@export var palette: PackedColorArray = PackedColorArray([
	Color("e6194b"), Color("3cb44b"), Color("4363d8"), Color("f58231"),
	Color("911eb4"), Color("42d4f4"), Color("f032e6"), Color("bfef45"),
]):
	set(v):
		palette = v
		_queue_rebuild()

@export_group("Shape")
@export_range(0.0, 0.95, 0.01) var hole_ratio: float = 0.0:
	set(v):
		hole_ratio = v
		_queue_rebuild()
@export_range(-180.0, 180.0, 1.0) var start_angle: float = 0.0:
	set(v):
		start_angle = v
		_queue_rebuild()
@export var clockwise: bool = true:
	set(v):
		clockwise = v
		_queue_rebuild()
@export_range(0.0, 20.0, 0.1) var gap_degrees: float = 0.0:
	set(v):
		gap_degrees = v
		_queue_rebuild()
@export_range(0.0, 64.0, 1.0) var padding: float = 8.0:
	set(v):
		padding = v
		_queue_rebuild()
@export_range(16, 256, 1) var segments_per_circle: int = 96:
	set(v):
		segments_per_circle = v
		_queue_rebuild()

@export_group("Outline")
@export_range(0.0, 10.0, 0.1) var outline_width: float = 0.0:
	set(v):
		outline_width = v
		_queue_rebuild()
@export var outline_color: Color = Color.BLACK:
	set(v):
		outline_color = v
		_queue_rebuild()

@export_group("Interaction")
@export var hoverable: bool = true
@export var hover_explode_px: float = 8.0
@export_range(0.0, 1.0, 0.01) var hover_brighten: float = 0.15
@export_multiline var tooltip_format: String = "{name}\n{value} ({percent}%)"

@export_group("Spawn")
@export var spawn_enabled: bool = true
@export var spawn_parent: NodePath
@export var replace_previous: bool = true
@export var spawn_at_cursor: bool = false

@export_group("Legend")
@export var legend_position: LegendPosition = LegendPosition.RIGHT:
	set(v):
		legend_position = v
		_queue_rebuild()
@export var legend_format: String = "{name} ({percent}%)":
	set(v):
		legend_format = v
		_queue_rebuild()
@export var legend_font_size: int = 0:
	set(v):
		legend_font_size = v
		_queue_rebuild()
@export_range(0, 4, 1) var percent_decimals: int = 1:
	set(v):
		percent_decimals = v
		_queue_rebuild()

@export_group("Center")
@export var center_text: String = "":
	set(v):
		center_text = v
		_queue_rebuild()
@export var center_font_size: int = 0:
	set(v):
		center_font_size = v
		_queue_rebuild()

@export_group("Animation")
@export var animate_duration: float = 0.6

var selected_key: int = -1

var _layout: BoxContainer
var _canvas: Control
var _legend: FlowContainer
var _center_label: Label

var _views: Array = []
var _ranges: Array = []
var _mids: Array = []
var _center := Vector2.ZERO
var _radius := 1.0
var _max_explode := 0.0
var _hovered := -1
var _rebuild_queued := false
var _white_tex: ImageTexture
var _spawned: Node

var _reveal: float = 1.0:
	set(v):
		_reveal = v
		_rebuild_geometry()


func _ready() -> void:
	_layout = %Layout
	_canvas = %Canvas
	_legend = %Legend
	_center_label = %CenterLabel
	_center_label.z_index = 1

	_canvas.resized.connect(_rebuild_geometry)
	_canvas.gui_input.connect(_on_canvas_input)
	_canvas.mouse_exited.connect(_set_hover.bind(-1))

	if not Engine.is_editor_hint():
		var own: Array[PieSlice] = []
		for s in slices:
			own.append(s.duplicate() if s else null)
		slices = own

	_rebuild_all()
	if animate_duration > 0.0 and not Engine.is_editor_hint():
		play_reveal()


func set_values(values: Dictionary, animate: bool = false) -> void:
	var seen := {}
	for key in values:
		var name := str(key)
		var s := get_slice(name)
		if s == null:
			s = PieSlice.new()
			s.label = name
			var arr: Array[PieSlice] = slices.duplicate()
			arr.append(s)
			slices = arr
		s.value = float(values[key])
		seen[name] = true
	for s in slices:
		if s and not seen.has(s.label):
			s.value = 0.0
	if animate:
		play_reveal()


func set_values_by_key(values: Dictionary, name_resolver: Callable, animate: bool = false) -> void:
	var seen := {}
	for k in values:
		var s := get_slice_by_key(int(k))
		if s == null:
			s = PieSlice.new()
			s.key = int(k)
			s.label = str(name_resolver.call(k))
			var arr: Array[PieSlice] = slices.duplicate()
			arr.append(s)
			slices = arr
		s.value = float(values[k])
		seen[int(k)] = true
	for s in slices:
		if s and not seen.has(s.key):
			s.value = 0.0
	if animate:
		play_reveal()


func get_slice(label: String) -> PieSlice:
	for s in slices:
		if s and s.label == label:
			return s
	return null


func get_slice_by_key(key: int) -> PieSlice:
	for s in slices:
		if s and s.key == key:
			return s
	return null


func set_slice_color(label: String, color: Color) -> void:
	var s := get_slice(label)
	if s:
		s.color = color


func set_slice_material(label: String, material: Material) -> void:
	var s := get_slice(label)
	if s:
		s.material = material


func set_slice_scene(label: String, scene: PackedScene) -> void:
	var s := get_slice(label)
	if s:
		s.spawn_scene = scene


func play_reveal() -> void:
	_reveal = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_reveal", 1.0, animate_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func refresh() -> void:
	_queue_rebuild()


func close_spawned() -> void:
	if is_instance_valid(_spawned):
		_spawned.queue_free()
	_spawned = null


func _set_slices(v: Array[PieSlice]) -> void:
	for s in slices:
		if s and s.changed.is_connected(_queue_rebuild):
			s.changed.disconnect(_queue_rebuild)
	slices = v
	for s in slices:
		if s and not s.changed.is_connected(_queue_rebuild):
			s.changed.connect(_queue_rebuild)
	_queue_rebuild()


func _total() -> float:
	var t := 0.0
	for s in slices:
		if s:
			t += s.value
	return t


func _color_of(i: int) -> Color:
	var s := slices[i]
	if s.color.a > 0.0:
		return s.color
	if palette.is_empty():
		return Color.WHITE
	return palette[i % palette.size()]


func _percent(s: PieSlice) -> float:
	var total := _total()
	return s.value / total * 100.0 if total > 0.0 else 0.0


func _format(fmt: String, s: PieSlice) -> String:
	return fmt.replace("{name}", s.label)\
		.replace("{value}", String.num(s.value))\
		.replace("{percent}", String.num(_percent(s), percent_decimals))


func _queue_rebuild() -> void:
	if _rebuild_queued:
		return
	_rebuild_queued = true
	_rebuild_all.call_deferred()


func _rebuild_all() -> void:
	_rebuild_queued = false
	if not is_node_ready():
		return
	_rebuild_geometry()
	_rebuild_legend()
	_rebuild_center()


func _unit(t: float) -> Vector2:
	var a := deg_to_rad(start_angle) + t * (1.0 if clockwise else -1.0)
	return Vector2(sin(a), -cos(a))


func _get_white() -> ImageTexture:
	if _white_tex == null:
		var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_white_tex = ImageTexture.create_from_image(img)
	return _white_tex


func _rebuild_geometry() -> void:
	if not is_node_ready():
		return
	for v in _views:
		if v:
			v.queue_free()
	_views.clear()
	_ranges.clear()
	_mids.clear()

	var total := _total()
	if total <= 0.0:
		return

	_max_explode = 0.0
	for s in slices:
		if s:
			_max_explode = maxf(_max_explode, s.explode)

	var size_px := _canvas.size
	_center = size_px / 2.0
	_radius = maxf((minf(size_px.x, size_px.y) / 2.0 - padding - hover_explode_px) / (1.0 + _max_explode), 1.0)

	var gap := deg_to_rad(gap_degrees)
	var cursor := 0.0

	for i in slices.size():
		_views.append(null)
		_ranges.append(Vector2(-1, -1))
		_mids.append(0.0)

		var s := slices[i]
		if s == null or s.value <= 0.0:
			continue

		var span := s.value / total * TAU * _reveal
		var t0 := cursor + gap / 2.0
		var t1 := cursor + span - gap / 2.0
		cursor += span
		if t1 <= t0:
			continue

		_ranges[i] = Vector2(t0, t1)
		_mids[i] = (t0 + t1) / 2.0

		var steps := maxi(2, ceili((t1 - t0) / TAU * segments_per_circle))
		var pts := PackedVector2Array()
		for k in steps + 1:
			pts.append(_center + _unit(lerpf(t0, t1, float(k) / steps)) * _radius)
		if hole_ratio > 0.0:
			for k in range(steps, -1, -1):
				pts.append(_center + _unit(lerpf(t0, t1, float(k) / steps)) * _radius * hole_ratio)
		else:
			pts.append(_center)

		var tex: Texture2D = s.texture if s.texture else _get_white()
		var tex_size := Vector2(tex.get_size())
		var origin := _center - Vector2(_radius, _radius)
		var uvs := PackedVector2Array()
		for p in pts:
			uvs.append((p - origin) / (_radius * 2.0) * tex_size)

		var poly := Polygon2D.new()
		poly.polygon = pts
		poly.uv = uvs
		poly.texture = tex
		poly.material = _make_material(s, i)
		_canvas.add_child(poly)

		if outline_width > 0.0:
			var line := Line2D.new()
			line.points = pts
			line.closed = true
			line.width = outline_width
			line.default_color = outline_color
			poly.add_child(line)

		_views[i] = poly
		_refresh_view(i)


func _make_material(s: PieSlice, i: int) -> Material:
	if s.material is ShaderMaterial:
		var sm := (s.material as ShaderMaterial).duplicate() as ShaderMaterial
		sm.set_shader_parameter("percent", _percent(s))
		sm.set_shader_parameter("slice_index", i)
		sm.set_shader_parameter("hover", 0.0)
		return sm
	return s.material


func _refresh_view(i: int) -> void:
	if i < 0 or i >= _views.size() or _views[i] == null:
		return
	var poly: Polygon2D = _views[i]
	var hovered := i == _hovered
	var c := _color_of(i)
	poly.color = c.lightened(hover_brighten) if hovered else c
	var off := slices[i].explode * _radius + (hover_explode_px if hovered else 0.0)
	poly.position = _unit(_mids[i]) * off
	if poly.material is ShaderMaterial:
		(poly.material as ShaderMaterial).set_shader_parameter("hover", 1.0 if hovered else 0.0)


func _rebuild_legend() -> void:
	for c in _legend.get_children():
		_legend.remove_child(c)
		c.queue_free()

	_legend.visible = legend_position != LegendPosition.NONE
	var side := legend_position in [LegendPosition.LEFT, LegendPosition.RIGHT]
	_layout.vertical = not side
	_legend.vertical = side
	_layout.move_child(_legend, 0 if legend_position in [LegendPosition.LEFT, LegendPosition.TOP] else 1)

	if legend_position == LegendPosition.NONE:
		return

	for i in slices.size():
		var s := slices[i]

		if s == null or s.value <= 0.0:
			continue

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var sw := ColorRect.new()
		sw.custom_minimum_size = Vector2(14, 14)
		sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		sw.color = _color_of(i)
		row.add_child(sw)

		var lb := Label.new()
		lb.text = _format(legend_format, s)
		if legend_font_size > 0:
			lb.add_theme_font_size_override("font_size", legend_font_size)
		row.add_child(lb)

		row.mouse_entered.connect(_set_hover.bind(i))
		row.mouse_exited.connect(_set_hover.bind(-1))
		row.gui_input.connect(_on_legend_row_input.bind(i))
		if s.spawn_scene != null:
			row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_legend.add_child(row)


func _rebuild_center() -> void:
	_center_label.text = center_text.replace("{total}", String.num(_total()))
	_center_label.visible = center_text != ""
	if center_font_size > 0:
		_center_label.add_theme_font_size_override("font_size", center_font_size)


func _on_canvas_input(event: InputEvent) -> void:
	if not hoverable:
		return
	if event is InputEventMouseMotion:
		_set_hover(_slice_at(event.position))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var i := _slice_at(event.position)
		if i >= 0:
			slice_clicked.emit(slices[i], i)
			_spawn_for(i)


func _on_legend_row_input(event: InputEvent, i: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if i < slices.size() and slices[i]:
			slice_clicked.emit(slices[i], i)
			_spawn_for(i)


func _spawn_for(i: int) -> void:
	var s := slices[i]
	if s == null:
		return
	selected_key = s.key

	if not spawn_enabled or Engine.is_editor_hint() or s.spawn_scene == null:
		return

	if replace_previous and is_instance_valid(_spawned):
		_spawned.queue_free()

	var parent: Node = get_node_or_null(spawn_parent) if not spawn_parent.is_empty() else get_tree().current_scene
	if parent == null:
		push_warning("PieChart: spawn_parent path is invalid.")
		return

	var node := s.spawn_scene.instantiate()
	if node.has_method("setup"):
		node.setup(s.key)
	parent.add_child(node)

	if spawn_at_cursor and node is Control:
		var c := node as Control
		var vp := get_viewport_rect().size
		c.global_position = get_global_mouse_position().clamp(Vector2.ZERO, (vp - c.size).max(Vector2.ZERO))

	_spawned = node
	slice_content_spawned.emit(node, s.key, s, i)


func _slice_at(pos: Vector2) -> int:
	var d := pos - _center
	var r := d.length()
	if r > _radius * (1.0 + _max_explode) + hover_explode_px or r < _radius * hole_ratio:
		return -1
	var dir := 1.0 if clockwise else -1.0
	var t := fposmod((atan2(d.x, -d.y) - deg_to_rad(start_angle)) * dir, TAU)
	for i in _ranges.size():
		var rg: Vector2 = _ranges[i]
		if t >= rg.x and t <= rg.y:
			return i
	return -1


func _set_hover(i: int) -> void:
	if not hoverable or i == _hovered:
		return
	var old := _hovered
	_hovered = i
	_refresh_view(old)
	_refresh_view(i)
	if i >= 0 and i < slices.size() and slices[i]:
		_canvas.tooltip_text = _format(tooltip_format, slices[i])
		_canvas.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND \
			if slices[i].spawn_scene != null else Control.CURSOR_ARROW
		slice_hovered.emit(slices[i], i)
	else:
		_canvas.tooltip_text = ""
		_canvas.mouse_default_cursor_shape = Control.CURSOR_ARROW
		slice_unhovered.emit()
