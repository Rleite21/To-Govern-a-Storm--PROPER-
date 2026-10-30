class_name CityDemographics
extends RefCounted

## Desvio máximo (±) aplicado a cada classe. 0.25 = cada percentagem pode variar até 25% para cima ou para baixo.
const DEFAULT_VARIANCE := 0.25

var population: int = 0
var social_classes: Dictionary = {}  # {SocialClass.Type: SocialClass}


func generate(total_population: int, density: CityDensity.Level, rng: RandomNumberGenerator = null, variance: float = DEFAULT_VARIANCE) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	population = total_population
	social_classes.clear()

	# 1) Base da densidade + desvio multiplicativo por classe
	var base := CityDensity.get_distribution(density)
	var shares := {}
	var sum := 0.0
	for class_type in base:
		var s: float = base[class_type] * rng.randf_range(1.0 - variance, 1.0 + variance)
		shares[class_type] = s
		sum += s

	# 2) Normalizar para somar exatamente 1.0
	for class_type in shares:
		shares[class_type] /= sum

	# 3) Converter em população inteira (método do maior resto, para a soma bater certo)
	var assigned := 0
	var remainders: Array = []  # [[class_type, resto], ...]
	for class_type in shares:
		var exact: float = shares[class_type] * population
		var count := floori(exact)
		var sc := SocialClass.new(class_type, shares[class_type])
		sc.population = count
		social_classes[class_type] = sc
		assigned += count
		remainders.append([class_type, exact - count])

	remainders.sort_custom(func(a, b): return a[1] > b[1])
	var leftover := population - assigned
	for i in leftover:
		social_classes[remainders[i % remainders.size()][0]].population += 1


func get_class_population(class_type: SocialClass.Type) -> int:
	return social_classes[class_type].population if social_classes.has(class_type) else 0


func get_class_share(class_type: SocialClass.Type) -> float:
	return social_classes[class_type].population_share if social_classes.has(class_type) else 0.0
