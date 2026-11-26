class_name CityEconomy
extends RefCounted

var sectors: Dictionary[Economy.Sector, EconomySector] = {}


func generate(
	population: float,
	traits: Array,
	specializations: Array[SectorSpecialization],
	rng: RandomNumberGenerator
) -> void:
	sectors.clear()

	var prevalence_by_sector := {}

	for spec in specializations:
		prevalence_by_sector[spec.sector] = spec.prevalence

	for s in Economy.Sector.values():
		var suit := SectorSuitability.get_suitability(traits, s)

		if suit <= 0.0:
			if prevalence_by_sector.has(s):
				push_warning(
					"Specialization on %s ignored: suitability is 0"
					% Economy.Sector.keys()[s]
				)
			continue

		var prevalence: float = (
			prevalence_by_sector[s]
			if prevalence_by_sector.has(s)
			else rng.randf_range(1.0, 1.3)
		)

		var sector := EconomySector.new(s)

		sector.size = Economy.roll_size(
			population,
			s,
			suit,
			prevalence,
			rng
		)

		sectors[s] = sector


func get_sector(type: Economy.Sector) -> EconomySector:
	return sectors.get(type)


func has_sector(type: Economy.Sector) -> bool:
	return sectors.has(type)


func total_size() -> float:
	var total := 0.0

	for sector in sectors.values():
		total += sector.size

	return total
