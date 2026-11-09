class_name SocialClass
extends RefCounted

var type: SocialClassEnums.Type
var population: int = 0
var population_share: float = 0.0
var convictions: Dictionary = {}
var traits: Array[SocialClassEnums.Trait] = []

var militancy: float = 0.0:
	set(value):
		militancy = clampf(value, SocialClassEnums.MILITANCY_MIN, SocialClassEnums.MILITANCY_MAX)

var consciousness: float = 0.0:
	set(value):
		consciousness = clampf(value, SocialClassEnums.CONSCIOUSNESS_MIN, SocialClassEnums.CONSCIOUSNESS_MAX)

var is_working: bool:
	get: return SocialClassEnums.is_working(type)


func _init(p_type := SocialClassEnums.Type.PEASANTS) -> void:
	type = p_type

func get_display_name() -> String:
	return SocialClassEnums.type_to_string(type)


func has_trait(t: SocialClassEnums.Trait) -> bool:
	return t in traits
