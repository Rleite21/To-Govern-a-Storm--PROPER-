class_name ClassModsDensity
extends RefCounted

const ANY := -1

static var _loaded := false
static var _effects: Dictionary = {}


# Soma os deltas da densidade da cidade, primeiro os de ANY e depois os da classe
static func apply(sc: SocialClass, density: CityDensity.Level) -> void:
	_ensure_loaded()
	var by_class: Dictionary = _effects.get(density, {})
	for key in [ANY, sc.type]:
		var fx: Dictionary = by_class.get(key, {})
		sc.apply_modifier(fx.get("m", 0.0), fx.get("c", 0.0))


# Carrega a tabela uma única vez
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var T := SocialClassEnums.Type
	var D := CityDensity.Level

	# Densidade -> { classe ou ANY -> {m, c} }
	_effects = {
		D.VERY_RURAL: {T.PEASANTS: {"m": 2.0, "c": -6.0}},
		D.RURAL: {T.PEASANTS: {"c": -3.0}},
		D.VERY_URBANISED: {T.WORKING_CLASS: {"m": 4.0, "c": 4.0}},
		D.METROPOLITAN: {
			ANY: {"c": 5.0},
			T.WORKING_CLASS: {"m": 6.0, "c": 4.0},
		},
	}
