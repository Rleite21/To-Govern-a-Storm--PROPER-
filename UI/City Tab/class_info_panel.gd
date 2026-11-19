class_name ClassInfoPanel
extends Panel

static var current_city: City

const TEXT_COLOR := Color.WHITE
const MARGIN := 8.0
const MIN_WIDTH := 260.0

var _type: int = -1
var _root: VBoxContainer


func _ready() -> void:
	add_to_group("class_info_panels")
	_type = SocialClassEnums.type_from_string(name)
	visibility_changed.connect(func(): if is_visible_in_tree(): refresh())
	refresh()


func refresh() -> void:
	if is_instance_valid(_root):
		remove_child(_root)
		_root.queue_free()

	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 6)
	_root.position = Vector2(MARGIN, MARGIN)
	add_child(_root)
	_root.minimum_size_changed.connect(_fit_to_content)

	_populate(_root)

	custom_minimum_size = Vector2(MIN_WIDTH, 0)
	_fit_to_content.call_deferred()


func _fit_to_content() -> void:
	if not is_instance_valid(_root):
		return
	var content := _root.get_combined_minimum_size()
	_root.size = Vector2(maxf(MIN_WIDTH, content.x + MARGIN * 2.0) - MARGIN * 2.0, content.y)
	custom_minimum_size = Vector2(
		maxf(MIN_WIDTH, content.x + MARGIN * 2.0),
		content.y + MARGIN * 2.0
	)
	size = custom_minimum_size


func _populate(root: VBoxContainer) -> void:
	var title := _label("")
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	if _type < 0:
		title.text = name
		root.add_child(_label("Nome de node '%s' não corresponde a nenhuma classe." % name))
		return

	title.text = SocialClassEnums.type_to_string(_type)

	var city := current_city
	if city == null:
		root.add_child(_label("Sem cidade selecionada."))
		return

	var classes: Dictionary = city.demographics.social_classes
	if not classes.has(_type):
		root.add_child(_label("Sem dados para esta classe."))
		return

	var sc: SocialClass = classes[_type]

	root.add_child(HSeparator.new())
	root.add_child(_stat_row("Consciousness", sc.consciousness, 100.0))
	root.add_child(_stat_row("Militancy", sc.militancy, 100.0))

	var wealth = sc.get("wealth")
	root.add_child(_text_row("Wealth", "—" if wealth == null else "%.1f" % float(wealth)))

	root.add_child(HSeparator.new())
	var traits_title := _label("Traits")
	traits_title.add_theme_font_size_override("font_size", 16)
	root.add_child(traits_title)

	if sc.traits.is_empty():
		root.add_child(_label("Nenhum"))
	else:
		for t in sc.traits:
			root.add_child(_label("• " + SocialClassEnums.trait_to_string(t)))


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", TEXT_COLOR)
	return l


func _text_row(title: String, value: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var a := _label(title)
	a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(a)
	row.add_child(_label(value))
	return row


func _stat_row(title: String, value: float, max_value: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var a := _label(title)
	a.custom_minimum_size.x = 110
	row.add_child(a)

	var bar := ProgressBar.new()
	bar.max_value = max_value
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(120, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)

	row.add_child(_label("%.1f" % value))
	return row
