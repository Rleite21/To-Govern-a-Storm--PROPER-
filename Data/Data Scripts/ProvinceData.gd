extends Resource
class_name ProvinceData

@export var province_name: String
@export_multiline var description: String
@export var population: int
var cities: Dictionary[String, City] = {}
