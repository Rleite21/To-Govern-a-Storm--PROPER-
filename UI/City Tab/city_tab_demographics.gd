class_name CityTabDemographics
extends Control

signal closed

var _city: City

@onready var close_button: Button = %CloseButton
@onready var chart: PieChart = %DemographicsChart


func setup(city: City) -> void:
	_city = city


func _ready() -> void:
	close_button.pressed.connect(func(): closed.emit())
	if _city == null:
		return
	if _city.demographics.social_classes.is_empty():
		_city.initialize()
	fill(_city, chart)


static func fill(city: City, chart: PieChart) -> void:
	if chart == null:
		return

	var values: Dictionary = {}
	for type in city.demographics.social_classes:
		var sc: SocialClass = city.demographics.social_classes[type]
		values[type] = sc.population

	chart.set_values_by_key(values, SocialClassEnums.type_to_string, true)


static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values_by_key({}, SocialClassEnums.type_to_string)
