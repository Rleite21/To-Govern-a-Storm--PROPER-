class_name CityTabDemographics
extends RefCounted


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
