class_name CityTabEconomy
extends RefCounted


static func fill(city: City, chart: PieChart) -> void:
	if chart == null:
		return

	var values: Dictionary = {}

	for spec in city.data.specializations:
		if spec == null:
			continue

		values[Economy.Sector.keys()[spec.sector]] = Economy.roll_size(
			city.data.population,
			spec.sector,
			1.0,
			spec.prevalence
		)

	chart.set_values(values, true)


static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values({})
