class_name CityTabEconomy
extends Control

signal closed

var _city: City

@onready var close_button: Button = %CloseButton
@onready var ownership_chart: BoxContainer = %Ownership


func setup(city: City) -> void:
	_city = city


func _ready() -> void:
	close_button.pressed.connect(func(): closed.emit())
	if _city == null:
		return
	if _city.demographics.social_classes.is_empty():
		_city.initialize()
	fill(_city, chart)

static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values_by_key({}, SocialClassEnums.type_to_string)
