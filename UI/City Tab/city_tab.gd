
class_name CityTab
extends Control

signal closed

const MAIN_VBOX := "MarginContainer/ScrollContainer/VBox/"
const CHARTS_VBOX := "MarginContainer/ScrollContainer/VBox/ChartsBox/"

const DEMOGRAPHICS_SCENE: PackedScene = preload("res://tscn/UI/City_Tab_Demographics.tscn")
const ECONOMY_SCENE: PackedScene = preload("res://tscn/UI/City_Tab_Economy.tscn")

@onready var name_label: Label = get_node(MAIN_VBOX + "Header/NameLabel")
@onready var tier_label: Label = get_node(MAIN_VBOX + "Header/TierLabel")
@onready var close_button: Button = get_node(MAIN_VBOX + "Header/CloseButton")
@onready var province_label: Label = get_node(MAIN_VBOX + "Header/ProvinceLabel")

@onready var description_label: RichTextLabel = get_node(MAIN_VBOX + "DescriptionLabel")
@onready var population_label: Label = get_node(MAIN_VBOX + "Stats/PopulationLabel")
@onready var density_label: Label = get_node(MAIN_VBOX + "Stats/DensityLabel")

@onready var society_box: Container = get_node(MAIN_VBOX + "SocietyBox")
@onready var specializations_box: Container = get_node(MAIN_VBOX + "SpecializationsBox")
@onready var traits_box: Container = get_node(MAIN_VBOX + "TraitsBox")

@onready var demographics_box: VBoxContainer = get_node(CHARTS_VBOX)
@onready var demographics_chart: PieChart = get_node(CHARTS_VBOX + "DemographicsChart")
@onready var economy_chart: PieChart = get_node(CHARTS_VBOX + "EconomyChart")

@onready var tab_pop_button: Button = get_node(MAIN_VBOX + "Header/TabPop")
@onready var tab_economy_button: Button = get_node(MAIN_VBOX + "Header/TabEcon")

var _city: City
var _demographics_popup: Control
var _economy_popup: Control


func _ready() -> void:
	close_button.pressed.connect(close)
	tab_pop_button.pressed.connect(_open_demographics)
	tab_economy_button.pressed.connect(_open_economy)
	visible = false


func show_city(source: Variant) -> void:
	var city: City
	var data: CityData

	if source is City:
		city = source
		data = city.data
	elif source is CityData:
		data = source
		city = _find_city(data)

	if data == null:
		return

	_city = city
	tab_pop_button.disabled = city == null
	tab_economy_button.disabled = city == null

	CityTabInfo.fill(
		data,
		name_label,
		tier_label,
		province_label,
		description_label,
		population_label,
		density_label
	)

	CityTabSociety.fill(data, society_box, specializations_box, traits_box)

	if city != null:
		if city.demographics.social_classes.is_empty():
			city.initialize()

		fill_economy(city, economy_chart)
		CityTabDemographics.fill(city, demographics_chart)
	else:
		CityTabDemographics.clear(demographics_chart)
		push_warning("CityTab: não encontrei a City para '%s'." % data.city_name)

	visible = true
	ClassInfoPanel.current_city = city
	get_tree().call_group("class_info_panels", "refresh")


func _find_city(data: CityData) -> City:
	var provinces := get_node_or_null("../Portugal/Provinces")

	if provinces == null:
		push_error("CityTab: não foi encontrado ../Portugal/Provinces")
		return null

	for province in provinces.get_children():
		for node in province.get_children():
			if node is City and node.data == data:
				return node

	return null


func _open_demographics() -> void:
	if _city == null:
		return

	if is_instance_valid(_demographics_popup):
		_demographics_popup.queue_free()

	var popup := DEMOGRAPHICS_SCENE.instantiate() as Control

	if popup.has_method("setup"):
		popup.setup(_city)

	add_child(popup)
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.mouse_filter = Control.MOUSE_FILTER_STOP

	if popup.has_signal("closed"):
		popup.closed.connect(_close_demographics)

	_demographics_popup = popup


func _close_demographics() -> void:
	if is_instance_valid(_demographics_popup):
		_demographics_popup.queue_free()

	_demographics_popup = null


func _open_economy() -> void:
	if _city == null:
		return

	if is_instance_valid(_economy_popup):
		_economy_popup.queue_free()

	var popup := ECONOMY_SCENE.instantiate() as Control

	if popup.has_method("setup"):
		popup.setup(_city)

	add_child(popup)
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.mouse_filter = Control.MOUSE_FILTER_STOP

	if popup.has_signal("closed"):
		popup.closed.connect(_close_economy)

	_economy_popup = popup


func _close_economy() -> void:
	if is_instance_valid(_economy_popup):
		_economy_popup.queue_free()

	_economy_popup = null


static func fill_economy(city: City, chart: PieChart) -> void:
	if chart == null or city.economy == null:
		return

	var values: Dictionary = {}

	for sector_type in city.economy.sectors:
		var sector: EconomySector = city.economy.sectors[sector_type]
		values[sector_type] = sector.size

	chart.set_values_by_key(
		values,
		Economy.display_name,
		true
	)


func close() -> void:
	_close_demographics()
	_close_economy()
	visible = false
	closed.emit()
