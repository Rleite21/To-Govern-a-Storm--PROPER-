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

const VBOX := "PanelContainer/VBox/"

@onready var name_label: Label = get_node(VBOX + "Header/NameLabel")
@onready var tier_label: Label = get_node(VBOX + "Header/TierLabel")
@onready var close_button: Button = get_node(VBOX + "Header/CloseButton")
@onready var province_label: Label = get_node(VBOX + "ProvinceLabel")
@onready var description_label: RichTextLabel = get_node(VBOX + "DescriptionLabel")
@onready var population_label: Label = get_node(VBOX + "Stats/PopulationLabel")
@onready var density_label: Label = get_node(VBOX + "Stats/DensityLabel")
@onready var society_box: Container = get_node(VBOX + "SocietyBox")
@onready var specializations_box: Container = get_node(VBOX + "SpecializationsBox")
@onready var traits_box: Container = get_node(VBOX + "TraitsBox")

func _ready() -> void:
	close_button.pressed.connect(close)
	visible = false

func show_city(data: CityData) -> void:
	if data == null:
		return

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
	visible = true

func close() -> void:
	visible = false
	closed.emit()

# ---------------------------------------------------------------- helpers

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

# VERY_URBANISED -> "Very Urbanised"
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
