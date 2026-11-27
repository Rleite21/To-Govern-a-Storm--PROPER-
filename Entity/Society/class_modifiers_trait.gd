class_name ClassModsTrait
extends RefCounted

static var _loaded := false
static var _effects: Dictionary = {}


# Aplica o delta de um trait de classe (chamado pelo SocialClass.add_trait)
static func apply(sc: SocialClass, t: SocialClassEnums.Trait) -> void:
	_ensure_loaded()
	var fx: Dictionary = _effects.get(t, {})
	sc.apply_modifier(fx.get("m", 0.0), fx.get("c", 0.0))


# Carrega a tabela uma única vez
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var K := SocialClassEnums.Trait

	# Trait de classe -> {m, c}
	_effects = {
		K.LITERATE: {"c": 10.0},
		K.ILLITERATE: {"c": -10.0},
		K.ORGANIZED: {"m": 5.0, "c": 8.0},
		K.REBELLIOUS_HISTORY: {"m": 12.0},
		K.ISOLATED: {"c": -8.0},
		K.URBANIZED: {"c": 5.0},
		K.PATRIOTIC: {"m": -5.0},
	}
