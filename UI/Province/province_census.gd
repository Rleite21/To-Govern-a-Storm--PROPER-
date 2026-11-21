class_name ProvinceCensus
extends RefCounted

var population: int = 0
var city_count: int = 0
var largest_city: String = ""
var largest_city_population: int = 0
var avg_militancy: float = 0.0
var avg_consciousness: float = 0.0

var class_population: Dictionary = {}
var class_share: Dictionary = {}
var class_militancy: Dictionary = {}
var class_consciousness: Dictionary = {}


static func collect(province: Province) -> ProvinceCensus:
	var c := ProvinceCensus.new()
	var m_sum := {}
	var c_sum := {}
	for type in SocialClassEnums.Type.values():
		c.class_population[type] = 0
		m_sum[type] = 0.0
		c_sum[type] = 0.0

	if province == null or province.data == null:
		return c

	var total_m := 0.0
	var total_c := 0.0

	for city_name in province.data.cities:
		var city: City = province.data.cities[city_name]
		var demo := city.demographics
		if demo.social_classes.is_empty():
			continue

		c.city_count += 1
		c.population += demo.population
		if demo.population > c.largest_city_population:
			c.largest_city_population = demo.population
			c.largest_city = city_name

		for type in demo.social_classes:
			var sc: SocialClass = demo.social_classes[type]
			c.class_population[type] += sc.population
			m_sum[type] += sc.militancy * sc.population
			c_sum[type] += sc.consciousness * sc.population
			total_m += sc.militancy * sc.population
			total_c += sc.consciousness * sc.population

	for type in SocialClassEnums.Type.values():
		var pop: int = c.class_population[type]
		c.class_share[type] = float(pop) / c.population if c.population > 0 else 0.0
		c.class_militancy[type] = m_sum[type] / pop if pop > 0 else 0.0
		c.class_consciousness[type] = c_sum[type] / pop if pop > 0 else 0.0

	if c.population > 0:
		c.avg_militancy = total_m / c.population
		c.avg_consciousness = total_c / c.population

	return c
