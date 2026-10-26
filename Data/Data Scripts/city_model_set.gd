class_name CityModelSet
extends Resource

@export var capital: PackedScene
@export var large: PackedScene
@export var medium: PackedScene
@export var small: PackedScene

func get_scene(tier: CityTier.Type) -> PackedScene:
	match tier:
		CityTier.Type.CAPITAL: return capital
		CityTier.Type.LARGE: return large
		CityTier.Type.MEDIUM: return medium
		CityTier.Type.SMALL: return small
		_: return small
