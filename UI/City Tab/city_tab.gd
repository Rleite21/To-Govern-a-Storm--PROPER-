class_name CityTab
extends Control

signal closed

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

	CityTabInfo.fill(
		data,
		name_label,
		tier_label,
		province_label,
		description_label,
		population_label,
		density_label
	)

	CityTabSociety.fill(
		data,
		society_box,
		specializations_box,
		traits_box
	)

	if city != null:
		if city.demographics.social_classes.is_empty():
			city.initialize()

		CityTabDemographics.fill(city, demographics_chart)
	else:
		CityTabDemographics.clear(demographics_chart)
		push_warning("CityTab: não encontrei a City para '%s'." % data.city_name)

	visible = true


func close() -> void:
	visible = false
	closed.emit()


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
