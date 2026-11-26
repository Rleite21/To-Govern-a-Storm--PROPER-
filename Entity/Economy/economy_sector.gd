class_name EconomySector
extends RefCounted

var type: Economy.Sector

var size: float = 0.0
var production: Dictionary = {}
var workers: Dictionary[SocialClassEnums.Type, int] = {}
var class_ownership: Dictionary[SocialClassEnums.Type, float] = {}

var growth_rate: float = 0.0


func _init(p_type: Economy.Sector) -> void:
	type = p_type
