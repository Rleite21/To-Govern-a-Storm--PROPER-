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

# Returns false if the city can't be used
func initialize() -> bool:
	if data == null:
		push_error("City '%s' has no CityData!" % name)
		return false
	demographics.generate(data.population, data.density)
	economy.generate(demographics.population, data.traits, data.specializations)
	stance.flags = data.society
	return true
