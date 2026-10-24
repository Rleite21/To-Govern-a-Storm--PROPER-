class_name CityModelSet
extends Resource

@export var capital: PackedScene
@export var provincial_capital: PackedScene
@export var medium: PackedScene
@export var small: PackedScene

func get_scene(tier: CityTier.Type) -> PackedScene:
	match tier:
		CityTier.Type.CAPITAL: return capital
		CityTier.Type.PROVINCIAL_CAPITAL: return provincial_capital
		CityTier.Type.MEDIUM: return medium
		_: return small
