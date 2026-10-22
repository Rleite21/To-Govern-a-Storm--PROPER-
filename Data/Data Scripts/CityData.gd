extends Resource
class_name CityData

@export var city_name: String
@export_multiline var description: String
@export var province_name: String
@export var population: int
@export var specializations: Array[SectorSpecialization] = []
