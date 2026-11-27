extends Node3D
class_name City

@export var data: CityData

var demographics := CityDemographics.new()  # População e classes sociais
var economy := CityEconomy.new()            # Tamanho de cada setor
var stance := CulturalStance.new()          # Traços culturais

var city_name: String:
	get: return data.city_name
var population: int:
	get: return demographics.population
var density: CityDensity.Level:
	get: return data.density
var tier: CityTier.Type:
	get: return data.tier


func initialize(world_seed: int = 0) -> bool:
	if data == null:
		push_error("City '%s' has no CityData!" % name)
		return false

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(data.city_name) + world_seed

	# Traits da província a que a cidade pertence (vazio se não houver)
	var province := get_parent() as Province
	var province_traits: Array = province.data.traits if province != null and province.data != null else []

	demographics.generate(data.population, data.density, data.traits, rng)
	economy.generate(demographics.population, data.traits, data.specializations, rng, demographics, province_traits)
	stance.flags = data.society

	return true
