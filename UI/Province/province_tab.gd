class_name ProvinceTab
extends Control

signal closed
signal city_selected(city: City)

const MAIN_VBOX := "MarginContainer/ScrollContainer/VBox/"
const CHARTS_VBOX := "MarginContainer/ScrollContainer/VBox/ChartsBox/"

const TEXT_COLOR := Color.WHITE
const CARD_BG := Color(0.40, 0.38, 0.34, 0.95)
const BAR_BG := Color(0.28, 0.27, 0.24)
const BAR_FILL := Color(0.62, 0.61, 0.58)

@onready var name_label: Label = get_node(MAIN_VBOX + "Header/NameLabel")
@onready var close_button: Button = get_node(MAIN_VBOX + "Header/CloseButton")
@onready var description_label: RichTextLabel = get_node(MAIN_VBOX + "DescriptionLabel")

@onready var population_label: Label = get_node(MAIN_VBOX + "Stats/PopulationLabel")
@onready var cities_label: Label = get_node(MAIN_VBOX + "Stats/CitiesLabel")
@onready var largest_city_label: Label = get_node(MAIN_VBOX + "Stats/LargestCityLabel")
@onready var average_label: Label = get_node(MAIN_VBOX + "Stats/AverageLabel")

@onready var demographics_chart: PieChart = get_node(CHARTS_VBOX + "DemographicsChart")

@onready var classes_box: Container = get_node(MAIN_VBOX + "ClassesBox")
@onready var traits_box: Container = get_node(MAIN_VBOX + "TraitsBox")
@onready var cities_box: Container = get_node(MAIN_VBOX + "CitiesBox")

var _province: Province


func _ready() -> void:
	close_button.pressed.connect(close)

	description_label.fit_content = true
	description_label.add_theme_color_override("default_color", name_label.get_theme_color("font_color"))

	visible = false


func show_province(province: Province) -> void:
	if province == null or province.data == null:
		return

	_province = province
	var data := province.data
	var census := ProvinceCensus.collect(province)

	name_label.text = data.province_name
	description_label.text = data.description

	_fill_stats(census)
	_fill_chart(census)
	_fill_classes(census)
	_fill_traits(data)
	_fill_cities(province)

	visible = true


func close() -> void:
	visible = false
	closed.emit()


# ---------------------------------------------------------------- Stats

func _fill_stats(census: ProvinceCensus) -> void:
	population_label.text = "Population: %s" % _fmt_int(census.population)
	cities_label.text = "Cities: %d" % census.city_count
	if census.largest_city != "":
		largest_city_label.text = "Largest city: %s (%s)" % [census.largest_city, _fmt_int(census.largest_city_population)]
	else:
		largest_city_label.text = "Largest city: —"
	average_label.text = "Avg. militancy: %.1f   Avg. consciousness: %.1f" % [census.avg_militancy, census.avg_consciousness]


# ---------------------------------------------------------------- Chart

func _fill_chart(census: ProvinceCensus) -> void:
	var values := {}
	for type in census.class_population:
		values[type] = census.class_population[type]
	demographics_chart.set_values_by_key(values, SocialClassEnums.type_to_string, true)


# ---------------------------------------------------------------- Classes

func _fill_classes(census: ProvinceCensus) -> void:
	_clear(classes_box)
	classes_box.add_theme_constant_override("separation", 8)

	for type in SocialClassEnums.Type.values():
		classes_box.add_child(_class_card(
			SocialClassEnums.type_to_string(type),
			census.class_population[type],
			census.class_share[type],
			census.class_consciousness[type],
			census.class_militancy[type],
		))


func _class_card(title: String, population: int, share: float, consciousness: float, militancy: float) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = CARD_BG
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	vbox.add_child(_label(title, 26))
	vbox.add_child(HSeparator.new())

	vbox.add_child(_text_row("Population", "%s (%.1f%%)" % [_fmt_int(population), share * 100.0]))
	vbox.add_child(_bar_row("Consciousness", consciousness))
	vbox.add_child(_bar_row("Militancy", militancy))

	return card


func _text_row(left: String, right: String) -> Control:
	var row := HBoxContainer.new()

	var l := _label(left)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)

	var r := _label(right)
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.size_flags_horizontal = Control.SIZE_SHRINK_END
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(r)

	return row


func _bar_row(label_text: String, value: float) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var l := _label(label_text)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.size_flags_horizontal = Control.SIZE_FILL
	l.custom_minimum_size.x = 120
	row.add_child(l)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.custom_minimum_size = Vector2(60, 16)

	var bg := StyleBoxFlat.new()
	bg.bg_color = BAR_BG
	bg.set_corner_radius_all(8)
	var fill := StyleBoxFlat.new()
	fill.bg_color = BAR_FILL
	fill.set_corner_radius_all(8)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)

	var v := _label("%.1f" % value)
	v.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.size_flags_horizontal = Control.SIZE_FILL
	v.custom_minimum_size.x = 50
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(v)

	return row


# ---------------------------------------------------------------- Traits

func _fill_traits(data: ProvinceData) -> void:
	_clear(traits_box)

	if data.traits.is_empty():
		traits_box.add_child(_label("None"))
		return

	for cat in ProvinceTrait.Category.values():
		var entries := data.traits.filter(func(e): return e != null and e.category == cat)
		if entries.is_empty():
			continue
		traits_box.add_child(_label(ProvinceTrait.Category.keys()[cat].capitalize(), 15))
		for e in entries:
			traits_box.add_child(_label("• %s [%s]" % [e.get_display_name(), ProvinceTraitEntry.Strength.keys()[e.strength].capitalize()]))


# ---------------------------------------------------------------- Cities

func _fill_cities(province: Province) -> void:
	_clear(cities_box)

	for city_name in province.data.cities:
		var city: City = province.data.cities[city_name]
		var btn := Button.new()
		btn.text = "%s (%s)" % [city_name, _fmt_int(city.population)]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(): city_selected.emit(city))
		cities_box.add_child(btn)


# ---------------------------------------------------------------- Helpers

func _clear(box: Container) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _label(text: String, font_size: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_color_override("font_color", TEXT_COLOR)
	if font_size > 0:
		l.add_theme_font_size_override("font_size", font_size)
	return l


func _fmt_int(n: int) -> String:
	var s := str(n)
	var out := ""
	for i in s.length():
		if i > 0 and (s.length() - i) % 3 == 0:
			out += " "
		out += s[i]
	return out
