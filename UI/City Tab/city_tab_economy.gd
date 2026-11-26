
class_name CityTabEconomy
extends Control

signal closed

var _city: City

@onready var close_button: Button = %CloseButton
@onready var sectors_chart: PieChart = %SectorsChart
@onready var ownership_container: VBoxContainer = %Ownership


func setup(city: City) -> void:
	_city = city


func _ready() -> void:
	close_button.pressed.connect(func(): closed.emit())

	if _city == null:
		return

	if _city.economy == null or _city.economy.sectors.is_empty():
		_city.initialize()

	fill_sectors(_city, sectors_chart)
	fill_ownership(_city, ownership_container)


static func fill_sectors(city: City, chart: PieChart) -> void:
	if chart == null or city.economy == null:
		return

	var values: Dictionary = {}

	for type in city.economy.sectors:
		var sector: EconomySector = city.economy.sectors[type]
		values[type] = sector.size

	chart.set_values_by_key(
		values,
		Economy.display_name,
		true
	)


static func fill_ownership(city: City, container: VBoxContainer) -> void:
	if container == null or city.economy == null:
		return

	for child in container.get_children():
		child.queue_free()

	for sector_type in city.economy.sectors:
		var sector: EconomySector = city.economy.sectors[sector_type]

		if sector.class_ownership.is_empty():
			continue

		var title := Label.new()
		title.text = Economy.display_name(sector_type)
		container.add_child(title)

		var chart := PieChart.new()
		chart.name = "OwnershipChart_%s" % sector_type
		chart.custom_minimum_size = Vector2(0, 220)
		chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		container.add_child(chart)

		var values: Dictionary = {}

		for class_type in sector.class_ownership:
			values[class_type] = sector.class_ownership[class_type]

		chart.set_values_by_key(
			values,
			SocialClassEnums.type_to_string,
			true
		)


static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values_by_key({}, Economy.display_name)
