class_name CityTab
extends Control

signal closed

# Mesma ordem do @export_flags em CityData
const SOCIETY_FLAGS: Array[String] = [
	"Cosmopolitan", "Militant", "Rebellious", "Secular", "Intellectual",
	"Modernist", "Provincial", "Rugged", "Traditional", "Nostalgic",
	"Clerical", "Communitarian", "Deeply Traditional", "Austere",
	"Frontier Minded", "Progressive", "Patriotic"
]

const VBOX := "MarginContainer/ScrollContainer/VBox/"

@onready var name_label: Label = get_node(VBOX + "Header/NameLabel")
@onready var tier_label: Label = get_node(VBOX + "Header/TierLabel")
@onready var close_button: Button = get_node(VBOX + "Header/CloseButton")
@onready var province_label: Label = get_node(VBOX + "Header/ProvinceLabel")
@onready var description_label: RichTextLabel = get_node(VBOX + "DescriptionLabel")
@onready var population_label: Label = get_node(VBOX + "Stats/PopulationLabel")
@onready var density_label: Label = get_node(VBOX + "Stats/DensityLabel")
@onready var society_box: Container = get_node(VBOX + "SocietyBox")
@onready var specializations_box: Container = get_node(VBOX + "SpecializationsBox")
@onready var traits_box: Container = get_node(VBOX + "TraitsBox")
@onready var demographics_chart: PieChart = get_node(VBOX + "DemographicsChart")


func _ready() -> void:
	close_button.pressed.connect(close)
	visible = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		accept_event()

func show_city(source: Variant) -> void:
	var city: City = null
	var data: CityData = null

	if source is City:
		city = source
		data = city.data

	if source is CityData:
		data = source
		city = _find_city(data)

	if data == null:
		return

	_show_data(data)

	if city != null:
		if city.demographics.social_classes.is_empty():
			city.initialize()
		_fill_demographics(city)

	else:
		push_warning("CityTab: não encontrei a City para '%s'." % data.city_name)
		_clear_demographics()

	visible = true

func close() -> void:
	visible = false
	closed.emit()


func _show_data(data: CityData) -> void:
	name_label.text = data.city_name
	tier_label.text = _enum_text(CityTier.Type, data.tier)
	province_label.text = data.province_name
	description_label.text = data.description
	population_label.text = _format_number(data.population)
	density_label.text = _enum_text(CityDensity.Level, data.density)

	_fill_chips(society_box, _society_names(data.society))

	var trait_names: Array[String] = []
	for t in data.traits:
		trait_names.append(_enum_text(CityTrait.Type, t))
	_fill_chips(traits_box, trait_names)

	_fill_specializations(data)

func _fill_demographics(city: City) -> void:
	print("[DEBUG] A chamar _fill_demographics()")
	if demographics_chart == null:
		push_warning("DemographicsChart não encontrado!")
		return

	print("\n--- Demografia: ", city.data.city_name, " ---")

	var values: Dictionary = {}

	for type in city.demographics.social_classes:
		var sc: SocialClass = city.demographics.social_classes[type]
		print(sc.get_display_name(), " | Population: ", sc.population)
		values[sc.get_display_name()] = sc.population

	print("Valores enviados ao gráfico: ", values)
	demographics_chart.set_values(values, true)

func _clear_demographics() -> void:
	if demographics_chart != null:
		demographics_chart.set_values({})

func _fill_chips(box: Node, names: Array[String]) -> void:
	_clear(box)
	for n in names:
		var chip := Label.new()
		chip.text = n
		box.add_child(chip)

func _fill_specializations(data: CityData) -> void:
	_clear(specializations_box)
	for spec in data.specializations:
		if spec == null:
			continue
		var line := Label.new()
		line.text = "%s  ×%s" % [
			_enum_text(Economy.Sector, spec.sector),
			str(snappedf(spec.prevalence, 0.05))
		]
		specializations_box.add_child(line)


########### HELPERS ##########	

func _find_city(data: CityData) -> City:
	var provinces := get_node_or_null("../Portugal/Provinces")

	if provinces == null:
		push_error("CityTab: não foi encontrado ../Portugal/Provinces")
		return null

	for province in provinces.get_children():
		for node in province.get_children():
			if node is City:
				var city := node as City

				if city.data == data:
					return city

	return null

func _clear(box: Node) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()

func _society_names(flags: int) -> Array[String]:
	var out: Array[String] = []
	for i in range(SOCIETY_FLAGS.size()):
		if flags & (1 << i):
			out.append(SOCIETY_FLAGS[i])
	return out


func _enum_text(enum_dict: Dictionary, value: int) -> String:
	var key = enum_dict.find_key(value)
	if key == null:
		return "?"
	return String(key).replace("_", " ").capitalize()

func _format_number(n: int) -> String:
	var s := str(n)
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = " " + out
	return out
