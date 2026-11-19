extends Resource
class_name ProvinceData

@export var province_name: String
@export_multiline var description: String
@export var population: int
@export var mesh: Mesh                    
@export var material: Material               
@export var traits: Array[ProvinceTraitEntry] = []
var cities: Dictionary[String, City] = {}

func has_trait(category: ProvinceTrait.Category, value: int) -> bool:
	return get_trait(category, value) != null


func get_trait(category: ProvinceTrait.Category, value: int) -> ProvinceTraitEntry:
	for e in traits:
		if e.category == category and e.value == value:
			return e
	return null


func add_trait(category: ProvinceTrait.Category, value: int, strength: ProvinceTraitEntry.Strength = ProvinceTraitEntry.Strength.MODERATE) -> bool:
	if has_trait(category, value):
		return false
	traits.append(ProvinceTraitEntry.make(category, value, strength))
	return true


func remove_trait(category: ProvinceTrait.Category, value: int) -> void:
	for i in range(traits.size() - 1, -1, -1):
		if traits[i].category == category and traits[i].value == value:
			traits.remove_at(i)
