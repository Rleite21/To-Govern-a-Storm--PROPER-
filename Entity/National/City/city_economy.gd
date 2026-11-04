class_name CityEconomy
extends RefCounted

var sizes := PackedFloat32Array()  # indexado por Economy.Sector

func _init() -> void:
	sizes.resize(Economy.Sector.size())

func generate(population: float, traits: Array, specializations: Array[SectorSpecialization], rng: RandomNumberGenerator) -> void:
	sizes.fill(0.0)

	var prevalence_by_sector := {}
	for spec in specializations:
		prevalence_by_sector[spec.sector] = spec.prevalence

	for s in Economy.Sector.values():
		var suit := SectorSuitability.get_suitability(traits, s)
		if suit <= 0.0:
			if prevalence_by_sector.has(s):
				push_warning("Specialization on %s ignored: suitability is 0 (missing trait?)" % Economy.Sector.keys()[s])
			continue
		var prevalence: float = prevalence_by_sector[s] if prevalence_by_sector.has(s) else rng.randf_range(1.0, 1.3)
		sizes[s] = Economy.roll_size(population, s, suit, prevalence, rng)

func get_size(sector: Economy.Sector) -> float:
	return sizes[sector]

func has_sector(sector: Economy.Sector) -> bool:
	return sizes[sector] > 0.0

func total_size() -> float:
	var t := 0.0
	for v in sizes:
		t += v
	return t
