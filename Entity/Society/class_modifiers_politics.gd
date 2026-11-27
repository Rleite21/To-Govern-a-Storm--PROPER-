
class_name ClassModifiersPolitics
extends RefCounted

const ANY := -1

static var _loaded := false
static var _city_trait_effects: Dictionary = {}
static var _class_trait_effects: Dictionary = {}
static var _trait_rules: Array = []


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var T := SocialClassEnums.Type
	var K := SocialClassEnums.Trait
	var C := CityTrait.Type
	var D := CityDensity.Level

	# City trait -> { class or ANY -> {m, c} }
	_city_trait_effects = {
		C.PROMINENT_GOVERNMENT_INSTITUTIONS: {
			ANY: {"c": 4.0},
			T.MIDDLE_CLASS: {"c": 3.0},
		},
		C.PROMINENT_MILITARY_BASES: {
			ANY: {"m": -3.0},
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
		C.BUREAUCRATIC_CENTER: {
			ANY: {"c": 3.0},
			T.MIDDLE_CLASS: {"c": 5.0},
		},
		C.BLESSINGS_OF_THE_REGENERACAO: {
			ANY: {"m": -3.0},
			T.INDUSTRIALISTS: {"c": 2.0},
		},
	}

	# Class trait -> {m, c}
	_class_trait_effects = {
		K.LITERATE: {"c": 10.0},
		K.ILLITERATE: {"c": -10.0},
		K.ORGANIZED: {"m": 5.0, "c": 8.0},
		K.REBELLIOUS_HISTORY: {"m": 12.0},
		K.ISOLATED: {"c": -8.0},
		K.URBANIZED: {"c": 5.0},
		K.PATRIOTIC: {"m": -5.0},
	}

	# Political trait rules
	_trait_rules = [
		# City traits
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.PEASANTS, "trait": K.TRADITIONALIST, "chance": 0.40},
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.PEASANTS, "trait": K.ILLITERATE, "chance": 0.30},
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.ARISTOCRATS, "trait": K.CORRUPT_ELITES, "chance": 0.20},
		{"city_trait": C.BUREAUCRATIC_CENTER, "class": T.ARISTOCRATS, "trait": K.CORRUPT_ELITES, "chance": 0.20},
		{"city_trait": C.PROMINENT_MILITARY_BASES, "class": ANY, "trait": K.PATRIOTIC, "chance": 0.40},
		{"city_trait": C.PROMINENT_GOVERNMENT_INSTITUTIONS, "class": T.MIDDLE_CLASS, "trait": K.PATRIOTIC, "chance": 0.25},
		{"city_trait": C.PROMINENT_ENTREPRENEURS, "class": T.MIDDLE_CLASS, "trait": K.PROGRESSIVE, "chance": 0.30},
		{"city_trait": C.POWERFUL_BOURGEOISIE, "class": T.MIDDLE_CLASS, "trait": K.PROGRESSIVE, "chance": 0.30},
		{"city_trait": C.BLESSINGS_OF_THE_REGENERACAO, "class": ANY, "trait": K.PROGRESSIVE, "chance": 0.35},

		# Rural density
		{"density": D.RURAL, "class": ANY, "trait": K.DEVOUT, "chance": 0.20},

		# Metropolitan density
		{"density": D.METROPOLITAN, "class": ANY, "trait": K.SECULAR, "chance": 0.30},
		{"density": D.METROPOLITAN, "class": ANY, "trait": K.PROGRESSIVE, "chance": 0.25},
	]


# --- Stat effects --------------------------------------------------------

static func apply_city_effects(sc: SocialClass, city_traits: Array) -> void:
	_ensure_loaded()

	for ct in city_traits:
		var by_class: Dictionary = _city_trait_effects.get(ct, {})

		for key in [ANY, sc.type]:
			var fx: Dictionary = by_class.get(key, {})
			sc.apply_modifier(
				fx.get("m", 0.0),
				fx.get("c", 0.0)
			)


static func apply_density_effects(sc: SocialClass, density: CityDensity.Level) -> void:
	_ensure_loaded()

	# Political modifiers from density are currently empty.
	# Density-related political traits are handled by roll_traits.


## Called from SocialClass.add_trait.
static func apply_trait_effects(sc: SocialClass, t: SocialClassEnums.Trait) -> void:
	_ensure_loaded()

	var fx: Dictionary = _class_trait_effects.get(t, {})

	sc.apply_modifier(
		fx.get("m", 0.0),
		fx.get("c", 0.0)
	)


# --- Trait rolls ---------------------------------------------------------

static func roll_traits(
	sc: SocialClass,
	city_traits: Array,
	density: CityDensity.Level,
	rng: RandomNumberGenerator,
	max_traits: int = 4
) -> void:
	_ensure_loaded()

	var fail_product := {}

	for rule in _trait_rules:
		if rule["class"] != ANY and rule["class"] != sc.type:
			continue

		var matches := false

		if rule.has("city_trait"):
			matches = rule["city_trait"] in city_traits
		elif rule.has("density"):
			matches = rule["density"] == density

		if not matches:
			continue

		var t = rule["trait"]
		fail_product[t] = fail_product.get(t, 1.0) * (1.0 - rule["chance"])

	# One RNG value per candidate, always consumed
	for t in fail_product:
		var chance: float = 1.0 - fail_product[t]
		var roll := rng.randf()

		if roll < chance and sc.traits.size() < max_traits:
			sc.add_trait(t)
