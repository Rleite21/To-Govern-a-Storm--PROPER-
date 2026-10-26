extends Resource
class_name ProvinceData

@export var province_name: String
@export_multiline var description: String
@export var population: int
@export var mesh: Mesh                    
@export var material: Material               
var cities: Dictionary[String, City] = {}
