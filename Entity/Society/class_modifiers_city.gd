class_name ClassModsCity
extends RefCounted

const ANY := -1

static var _loaded := false
static var _effects: Dictionary = {}


# Soma os deltas de cada trait da cidade, primeiro os de ANY e depois os da classe
static func apply(sc: SocialClass, city_traits: Array) -> void:
	_ensure_loaded()
	for ct in city_traits:
		var by_class: Dictionary = _effects.get(ct, {})
		for key in [ANY, sc.type]:
			var fx: Dictionary = by_class.get(key, {})
			sc.apply_modifier(fx.get("m", 0.0), fx.get("c", 0.0))


# Carrega a tabela uma única vez
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var T := SocialClassEnums.Type
	var C := CityTrait.Type

	# City trait -> { classe ou ANY -> {m: militancy, c: consciousness} }
	_effects = {
		C.FERTILE_LAND: {
			T.PEASANTS: {"m": -3.0},
			T.ARISTOCRATS: {"c": 2.0},
		},
		C.COAL_AND_IRON_DEPOSITS: {
			T.WORKING_CLASS: {"m": 5.0},
			T.INDUSTRIALISTS: {"c": 3.0},
		},
		C.COASTAL_LOCATION: {
			ANY: {"c": 3.0},
		},
		C.ESTABLISHED_FINANCIAL_INSTITUTIONS: {
			T.MIDDLE_CLASS: {"c": 4.0},
			T.INDUSTRIALISTS: {"m": -2.0, "c": 3.0},
		},
		C.PROMINENT_GOVERNMENT_INSTITUTIONS: {
			ANY: {"c": 4.0},
			T.MIDDLE_CLASS: {"c": 3.0},
		},
		C.PROMINENT_MILITARY_BASES: {
			ANY: {"m": -3.0},
		},
		C.GOOD_INFRASTRUCTURE: {
			ANY: {"c": 4.0},
		},
		C.PROMINENT_ENTREPRENEURS: {
			T.INDUSTRIALISTS: {"m": 2.0, "c": 4.0},
			T.MIDDLE_CLASS: {"c": 3.0},
		},
		C.BRIGHT_ACADEMIA: {
			ANY: {"c": 8.0},
			T.MIDDLE_CLASS: {"c": 5.0},
		},
		C.SKILLED_WORKFORCE: {
			T.WORKING_CLASS: {"c": 6.0},
		},
		C.POWERFUL_LANDOWNERS: {
			T.ARISTOCRATS: {"c": 6.0},
			T.PEASANTS: {"m": 6.0, "c": -4.0},
		},
		C.POWERFUL_BOURGEOISIE: {
			T.INDUSTRIALISTS: {"c": 5.0},
			T.MIDDLE_CLASS: {"c": 4.0},
			T.WORKING_CLASS: {"m": 4.0},
		},
		C.PROVINCIAL_CROSSROADS: {
			ANY: {"c": 3.0},
		},
		C.BUREAUCRATIC_CENTER: {
			ANY: {"c": 3.0},
			T.MIDDLE_CLASS: {"c": 5.0},
		},
		C.BLESSINGS_OF_THE_REGENERACAO: {
			ANY: {"m": -3.0},
			T.INDUSTRIALISTS: {"c": 2.0},
		},
		C.STRONG_RIVERINE_HUB: {
			ANY: {"c": 3.0},
			T.WORKING_CLASS: {"m": 3.0},
		},
	}
