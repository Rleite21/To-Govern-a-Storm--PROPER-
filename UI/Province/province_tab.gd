class_name ProvinceTab
extends Control

signal closed
signal city_selected(city: City)

const MAIN_VBOX := "MarginContainer/ScrollContainer/VBox/"
const CHARTS_VBOX := "MarginContainer/ScrollContainer/VBox/ChartsBox/"
const TEXT_COLOR := Color.WHITE

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


func _fill_stats(census: ProvinceCensus) -> void:
	population_label.text = "Population: %s" % _fmt_int(census.population)
	cities_label.text = "Cities: %d" % census.city_count
	if census.largest_city != "":
		largest_city_label.text = "Largest city: %s (%s)" % [census.largest_city, _fmt_int(census.largest_city_population)]
	else:
		largest_city_label.text = "Largest city: —"
	average_label.text = "Avg. militancy: %.1f   Avg. consciousness: %.1f" % [census.avg_militancy, census.avg_consciousness]


func _fill_chart(census: ProvinceCensus) -> void:
	var values := {}
	for type in census.class_population:
		values[type] = census.class_population[type]
	demographics_chart.set_values_by_key(values, SocialClassEnums.type_to_string, true)


func _fill_classes(census: ProvinceCensus) -> void:
	_clear(classes_box)
	classes_box.add_child(_label("Social classes", 17))
	for type in SocialClassEnums.Type.values():
		var line := "%s: %s (%.1f%%)  |  Militancy %.1f  |  Consciousness %.1f" % [
			SocialClassEnums.type_to_string(type),
			_fmt_int(census.class_population[type]),
			census.class_share[type] * 100.0,
			census.class_militancy[type],
			census.class_consciousness[type],
		]
		classes_box.add_child(_label(line))


func _fill_traits(data: ProvinceData) -> void:
	_clear(traits_box)
	traits_box.add_child(_label("Provincial traits", 17))

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


func _fill_cities(province: Province) -> void:
	_clear(cities_box)
	cities_box.add_child(_label("Cities", 17))

	for city_name in province.data.cities:
		var city: City = province.data.cities[city_name]
		var btn := Button.new()
		btn.text = "%s (%s)" % [city_name, _fmt_int(city.population)]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): city_selected.emit(city))
		cities_box.add_child(btn)


func _clear(box: Container) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _label(text: String, font_size: int = 0) -> Label:
	var l := Label.new()
	l.text = text
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
