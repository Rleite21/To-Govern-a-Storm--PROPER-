extends Node3D
class_name City

@export var data: CityData  # Dados fixos (não alterar em runtime)

var demographics := CityDemographics.new()  # População e classes sociais
var economy := CityEconomy.new()            # Tamanho de cada setor
var stance := CulturalStance.new()          # Traços culturais

# Atalhos para o que outros scripts mais usam
var city_name: String:
	get: return data.city_name
var population: int:
	get: return demographics.population
var density: CityDensity.Level:
	get: return data.density
var tier: CityTier.Type:
	get: return data.tier
	
# Returns false if the city can't be used
# Returns false if the city can't be used
func initialize(world_seed: int = 0) -> bool:
	if data == null:
		push_error("City '%s' has no CityData!" % name)
		return false

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(data.city_name) + world_seed

	demographics.generate(data.population, data.density, rng)
	economy.generate(demographics.population, data.traits, data.specializations)
	stance.flags = data.society
	
	return true
