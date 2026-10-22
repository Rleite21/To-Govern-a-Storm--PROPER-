class_name CityDemographics
extends RefCounted

const RANDOM_RANGE := 0.025

# Ordem: PEASANTS, PROLETARIAT, MIDDLE_CLASS, INDUSTRIALISTS, ARISTOCRATS
const DENSITY_SHARES := {
	CityDensity.Level.VERY_RURAL:     [0.85, 0.03, 0.08, 0.01, 0.03],
	CityDensity.Level.RURAL:          [0.70, 0.08, 0.15, 0.03, 0.04],
	CityDensity.Level.URBAN:          [0.35, 0.30, 0.25, 0.06, 0.04],
	CityDensity.Level.VERY_URBANISED: [0.10, 0.45, 0.32, 0.09, 0.04],
	CityDensity.Level.METROPOLITAN:   [0.05, 0.35, 0.40, 0.12, 0.08],
}

var population: int = 0
var class_shares := PackedFloat32Array()  # indexado por SocialClass.Type

func generate(p_population: int, density: CityDensity.Level) -> void:
	population = p_population
	var base: Array = DENSITY_SHARES[density]
	class_shares.resize(base.size())

	var total := 0.0
	for i in base.size():
		var v := maxf(float(base[i]) + randf_range(-RANDOM_RANGE, RANDOM_RANGE), 0.0)
		class_shares[i] = v
		total += v
	for i in class_shares.size():
		class_shares[i] /= total

func get_share(social_class: SocialClass.Type) -> float:
	return class_shares[social_class]

func get_count(social_class: SocialClass.Type) -> float:
	return population * class_shares[social_class]
