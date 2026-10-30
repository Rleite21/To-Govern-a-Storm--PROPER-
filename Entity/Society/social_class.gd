class_name SocialClass
extends RefCounted

enum Type { PEASANTS, WORKING_CLASS, MIDDLE_CLASS, INDUSTRIALISTS, ARISTOCRATS }

var type: Type
var population: int = 0            # Número de habitantes desta classe na cidade
var population_share: float = 0.0  # 0.0 a 1.0 (percentagem da população da cidade)
var convictions: Dictionary = {}   # mesmo formato usado em Politicians, Parties, etc.
var traits: Array = []

var militancy: float = 0.0:
	set(value):
		militancy = clampf(value, 0.0, 100.0)

var consciousness: float = 0.0:
	set(value):
		consciousness = clampf(value, 0.0, 100.0)


func _init(p_type: Type = Type.PEASANTS, p_share: float = 0.0) -> void:
	type = p_type
	population_share = p_share


func get_display_name() -> String:
	match type:
		Type.PEASANTS: return "Peasants"
		Type.WORKING_CLASS: return "Working Class"
		Type.MIDDLE_CLASS: return "Middle Class"
		Type.INDUSTRIALISTS: return "Industrialists"
		Type.ARISTOCRATS: return "Aristocrats"
	return "Unknown"


static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_").replace("&", "").replace("__", "_")
	return Type[key] if Type.has(key) else -1
