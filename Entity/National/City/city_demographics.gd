class_name CityDemographics
extends RefCounted

const DEFAULT_VARIANCE := 0.03
const MIN_SHARE := 0.005

var population: int = 0
var social_classes: Dictionary = {}  # {SocialClassEnums.Type: SocialClass}


func generate(
	total_population: int,
	density: CityDensity.Level,
	city_traits: Array = [],
	rng: RandomNumberGenerator = null
) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	population = total_population
	social_classes.clear()

	var distribution := CityDensity.get_distribution(density)

	# 1) Noisy shares, normalized to sum to 1.0
	var shares := {}
	var total := 0.0

	for type in distribution:
		var s: float = maxf(
			distribution[type] + rng.randf_range(-DEFAULT_VARIANCE, DEFAULT_VARIANCE),
			MIN_SHARE
		)
		shares[type] = s
		total += s

	# 2) Build each social class
	var assigned := 0
	var largest_type = null

	for type in distribution:
		# Create from template
		var sc := SocialClass.create(type, rng)

		# Apply city trait modifiers
		ClassModifiersEcon.apply_city_effects(sc, city_traits)
		ClassModifiersPolitics.apply_city_effects(sc, city_traits)

		# Apply population density modifiers
		ClassModifiersEcon.apply_density_effects(sc, density)
		ClassModifiersPolitics.apply_density_effects(sc, density)

		# Generate class traits
		ClassModifiersEcon.roll_traits(
			sc, city_traits, density, rng
		)

		ClassModifiersPolitics.roll_traits(
			sc, city_traits, density, rng
		)

		# Assign population
		sc.set_population(population, shares[type] / total)

		social_classes[type] = sc

		assigned += sc.population

		if largest_type == null or sc.population > social_classes[largest_type].population:
			largest_type = type

	# 3) Give rounding remainder to largest class
	if largest_type != null:
		social_classes[largest_type].population += population - assigned


func get_class_population(class_type: SocialClassEnums.Type) -> int:
	return social_classes[class_type].population if social_classes.has(class_type) else 0


func get_class_share(class_type: SocialClassEnums.Type) -> float:
	return social_classes[class_type].population_share if social_classes.has(class_type) else 0.0
