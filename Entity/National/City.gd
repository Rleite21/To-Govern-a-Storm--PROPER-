extends Node3D
class_name City

@export var data: CityData

var economy := CityEconomy.new()

func initialize() -> bool:
	if data == null:
		push_error("City '%s' has no CityData!" % name)
		return false
	economy.generate(data.population, data.traits, data.specializations)
	return true
