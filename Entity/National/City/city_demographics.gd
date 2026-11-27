class_name CityDemographics
extends RefCounted

const DEFAULT_VARIANCE := 0.03
const MIN_SHARE := 0.005

var population: int = 0
var social_classes: Dictionary = {}  # {SocialClassEnums.Type: SocialClass}


# Gera a demografia da cidade: shares por densidade, classes a partir dos templates,
# modifiers e população por classe
func generate(total_population: int, density: CityDensity.Level,
		city_traits: Array = [], rng: RandomNumberGenerator = null) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	population = total_population
	social_classes.clear()

	var distribution := CityDensity.get_distribution(density)

	# 1) Shares com ruído, normalizadas para somarem 1.0
	var shares := {}
	var total := 0.0
	for type in distribution:
		var s: float = maxf(distribution[type] + rng.randf_range(-DEFAULT_VARIANCE, DEFAULT_VARIANCE), MIN_SHARE)
		shares[type] = s
		total += s

	# 2) Cria cada classe: template -> modifiers -> população
	var assigned := 0
	var largest_type = null
	for type in distribution:
		var sc := SocialClass.create(type, rng)
		ClassModifiers.apply_all(sc, city_traits, density, rng)
		sc.set_population(population, shares[type] / total)
		social_classes[type] = sc
		assigned += sc.population
		if largest_type == null or sc.population > social_classes[largest_type].population:
			largest_type = type

	# 3) O resto do arredondamento vai para a maior classe, para o total ficar exato
	if largest_type != null:
		social_classes[largest_type].population += population - assigned


# População de uma classe (0 se não existir)
func get_class_population(class_type: SocialClassEnums.Type) -> int:
	return social_classes[class_type].population if social_classes.has(class_type) else 0


# Percentagem de uma classe, entre 0 e 1 (0 se não existir)
func get_class_share(class_type: SocialClassEnums.Type) -> float:
	return social_classes[class_type].population_share if social_classes.has(class_type) else 0.0
