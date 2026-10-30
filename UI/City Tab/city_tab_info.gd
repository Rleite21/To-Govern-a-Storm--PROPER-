class_name CityTabInfo
extends RefCounted

static func fill(
	data: CityData,
	name_label: Label,
	tier_label: Label,
	province_label: Label,
	description_label: RichTextLabel,
	population_label: Label,
	density_label: Label
) -> void:

	name_label.text = data.city_name
	tier_label.text = CityTabUtils.enum_text(CityTier.Type, data.tier)
	province_label.text = data.province_name
	description_label.text = data.description

	population_label.text = CityTabUtils.format_number(data.population)
	density_label.text = CityTabUtils.enum_text(CityDensity.Level, data.density)
