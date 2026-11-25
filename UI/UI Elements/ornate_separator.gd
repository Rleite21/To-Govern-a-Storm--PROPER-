@tool
class_name OrnateSeparator
extends HBoxContainer

@export var emblem_texture: Texture2D:
	set(v):
		emblem_texture = v
		_refresh()
@export_range(4, 256, 1) var emblem_height: int = 32:
	set(v):
		emblem_height = v
		_refresh()
@export var emblem_tint: Color = Color.WHITE:
	set(v):
		emblem_tint = v
		_refresh()

@export_group("Lines")
## Se desligado, usa o estilo do tema (ou o que definires nos HSeparator)
@export var override_line_style: bool = true:
	set(v):
		override_line_style = v
		_refresh()
@export var line_color: Color = Color(1, 1, 1, 0.35):
	set(v):
		line_color = v
		_refresh()
@export_range(1, 8, 1) var line_thickness: int = 1:
	set(v):
		line_thickness = v
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	var emblem: TextureRect = %Emblem
	emblem.visible = emblem_texture != null
	emblem.texture = emblem_texture
	emblem.modulate = emblem_tint
	if emblem_texture != null:
		var ratio := float(emblem_texture.get_width()) / float(emblem_texture.get_height())
		emblem.custom_minimum_size = Vector2(emblem_height * ratio, emblem_height)

	for line: HSeparator in [%LeftLine, %RightLine]:
		if override_line_style:
			var style := StyleBoxLine.new()
			style.color = line_color
			style.thickness = line_thickness
			style.vertical = false
			line.add_theme_stylebox_override("separator", style)
			line.add_theme_constant_override("separation", line_thickness)
		else:
			line.remove_theme_stylebox_override("separator")
			line.remove_theme_constant_override("separation")
