class_name CityDemographics
extends RefCounted

const DEFAULT_VARIANCE := 0.03

var population: int = 0
var social_classes: Dictionary = {}  # {SocialClass.Type: SocialClass}


func generate(total_population: int, density: CityDensity.Level, rng: RandomNumberGenerator = null) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	population = total_population
	social_classes.clear()

	var distribution := CityDensity.get_distribution(density)
	var total_weight := 1.0

	for type in distribution:
		var share: float = maxf(distribution[type] + rng.randf_range(-DEFAULT_VARIANCE, DEFAULT_VARIANCE), 0.005)
		var sc := SocialClass.new(type, share)
		sc.population = roundi(share * population)
		social_classes[type] = sc
		


func get_class_population(class_type: SocialClass.Type) -> int:
	return social_classes[class_type].population if social_classes.has(class_type) else 0

func get_class_share(class_type: SocialClass.Type) -> float:
	return social_classes[class_type].population_share if social_classes.has(class_type) else 0.0
