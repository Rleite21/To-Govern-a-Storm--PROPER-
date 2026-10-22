class_name CityEconomy
extends RefCounted

var sectors := {}  # Economy.Sector -> float (size)

func generate(population: float, traits: Array, specializations: Array[SectorSpecialization]) -> void:
	sectors.clear()

	var prevalence_by_sector := {}
	for spec in specializations:
		prevalence_by_sector[spec.sector] = spec.prevalence

	for s in Economy.Sector.values():
		var suit := SectorSuitability.get_suitability(traits, s)
		if suit <= 0.0:
			if prevalence_by_sector.has(s):
				push_warning("Specialization on %s ignored: suitability is 0 (missing trait?)" % Economy.Sector.keys()[s])
			continue
		var prevalence: float = prevalence_by_sector.get(s, randf_range(1.0, 1.3))
		sectors[s] = Economy.roll_size(population, s, suit, prevalence)
