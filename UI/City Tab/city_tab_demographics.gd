class_name CityTabDemographics
extends Control


signal closed

var _city: City

@onready var close_button: Button = %CloseButton

func setup(city: City) -> void:
	_city = city

func _ready() -> void:
	close_button.pressed.connect(func(): closed.emit())

static func fill(city: City, chart: PieChart) -> void:
	if chart == null:
		return

	var values: Dictionary = {}

	for type in city.demographics.social_classes:
		var sc: SocialClass = city.demographics.social_classes[type]
		values[sc.get_display_name()] = sc.population

	chart.set_values(values, true)


static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values({})
