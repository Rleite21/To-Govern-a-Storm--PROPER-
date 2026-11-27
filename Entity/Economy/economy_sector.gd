class_name EconomySector
extends RefCounted

var type: Economy.Sector

var size: float = 0.0
var production: Dictionary = {}
var workers: Dictionary[SocialClassEnums.Type, int] = {}
var ownership: Dictionary[OwnershipEnums.Owner, float] = {}

var growth_rate: float = 0.0


func _init(p_type: Economy.Sector) -> void:
	type = p_type


# Fração do setor que pertence a um dono (0 se não tiver)
func get_ownership(owner: OwnershipEnums.Owner) -> float:
	return ownership.get(owner, 0.0)


# Dono com maior fração (-1 se não houver donos)
func dominant_owner() -> int:
	var best := -1
	var best_share := 0.0
	for owner in ownership:
		if ownership[owner] > best_share:
			best_share = ownership[owner]
			best = owner
	return best
