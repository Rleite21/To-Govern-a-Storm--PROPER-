class_name ClassTraitRolls
extends RefCounted

const ANY := -1

static var _loaded := false
static var _rules: Array = []


# Sorteia traits para a classe: junta as regras ativas (cidade e densidade),
# combina as probabilidades e tenta adicionar cada trait candidato
static func roll(sc: SocialClass, city_traits: Array, density: CityDensity.Level,
		rng: RandomNumberGenerator, max_traits: int = 4) -> void:
	_ensure_loaded()

	# Probabilidade de NENHUMA das regras ativas disparar, por trait candidato
	var fail_product := {}
	for rule in _rules:
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

	# Um valor de RNG por candidato, sempre consumido, para manter a reprodutibilidade
	for t in fail_product:
		var chance: float = 1.0 - fail_product[t]
		var roll := rng.randf()
		if roll < chance and sc.traits.size() < max_traits:
			sc.add_trait(t)


# Carrega a lista de regras uma única vez
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var T := SocialClassEnums.Type
	var K := SocialClassEnums.Trait
	var C := CityTrait.Type
	var D := CityDensity.Level

	# A ordem é a prioridade quando há traits em conflito (as primeiras regras ganham)
	_rules = [
		# --- Traits de cidade ---
		{"city_trait": C.BRIGHT_ACADEMIA, "class": ANY, "trait": K.LITERATE, "chance": 0.50},
		{"city_trait": C.BRIGHT_ACADEMIA, "class": T.PEASANTS, "trait": K.LITERATE, "chance": 0.15},
		{"city_trait": C.SKILLED_WORKFORCE, "class": T.WORKING_CLASS, "trait": K.LITERATE, "chance": 0.35},
		{"city_trait": C.SKILLED_WORKFORCE, "class": T.WORKING_CLASS, "trait": K.ORGANIZED, "chance": 0.30},
		{"city_trait": C.COAL_AND_IRON_DEPOSITS, "class": T.WORKING_CLASS, "trait": K.ORGANIZED, "chance": 0.25},
		{"city_trait": C.STRONG_RIVERINE_HUB, "class": T.WORKING_CLASS, "trait": K.ORGANIZED, "chance": 0.20},
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.PEASANTS, "trait": K.TRADITIONALIST, "chance": 0.40},
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.PEASANTS, "trait": K.ILLITERATE, "chance": 0.30},
		{"city_trait": C.POWERFUL_LANDOWNERS, "class": T.ARISTOCRATS, "trait": K.CORRUPT_ELITES, "chance": 0.20},
		{"city_trait": C.BUREAUCRATIC_CENTER, "class": T.ARISTOCRATS, "trait": K.CORRUPT_ELITES, "chance": 0.20},
		{"city_trait": C.PROMINENT_MILITARY_BASES, "class": ANY, "trait": K.PATRIOTIC, "chance": 0.40},
		{"city_trait": C.PROMINENT_GOVERNMENT_INSTITUTIONS, "class": T.MIDDLE_CLASS, "trait": K.PATRIOTIC, "chance": 0.25},
		{"city_trait": C.PROMINENT_ENTREPRENEURS, "class": T.MIDDLE_CLASS, "trait": K.PROGRESSIVE, "chance": 0.30},
		{"city_trait": C.POWERFUL_BOURGEOISIE, "class": T.MIDDLE_CLASS, "trait": K.PROGRESSIVE, "chance": 0.30},
		{"city_trait": C.BLESSINGS_OF_THE_REGENERACAO, "class": ANY, "trait": K.PROGRESSIVE, "chance": 0.35},
		{"city_trait": C.GOOD_INFRASTRUCTURE, "class": ANY, "trait": K.URBANIZED, "chance": 0.30},
		{"city_trait": C.PROVINCIAL_CROSSROADS, "class": ANY, "trait": K.URBANIZED, "chance": 0.30},
		# --- Densidade: lado rural ---
		{"density": D.VERY_RURAL, "class": T.PEASANTS, "trait": K.ISOLATED, "chance": 0.50},
		{"density": D.VERY_RURAL, "class": T.PEASANTS, "trait": K.ILLITERATE, "chance": 0.45},
		{"density": D.VERY_RURAL, "class": ANY, "trait": K.TRADITIONALIST, "chance": 0.35},
		{"density": D.RURAL, "class": T.PEASANTS, "trait": K.ISOLATED, "chance": 0.25},
		{"density": D.RURAL, "class": T.PEASANTS, "trait": K.ILLITERATE, "chance": 0.30},
		{"density": D.RURAL, "class": ANY, "trait": K.DEVOUT, "chance": 0.20},
		# --- Densidade: lado urbano ---
		{"density": D.URBAN, "class": ANY, "trait": K.URBANIZED, "chance": 0.40},
		{"density": D.VERY_URBANISED, "class": ANY, "trait": K.URBANIZED, "chance": 0.70},
		{"density": D.VERY_URBANISED, "class": T.WORKING_CLASS, "trait": K.ORGANIZED, "chance": 0.30},
		{"density": D.METROPOLITAN, "class": ANY, "trait": K.URBANIZED, "chance": 0.90},
		{"density": D.METROPOLITAN, "class": ANY, "trait": K.SECULAR, "chance": 0.30},
		{"density": D.METROPOLITAN, "class": ANY, "trait": K.PROGRESSIVE, "chance": 0.25},
		{"density": D.METROPOLITAN, "class": T.WORKING_CLASS, "trait": K.ORGANIZED, "chance": 0.40},
		{"density": D.METROPOLITAN, "class": T.MIDDLE_CLASS, "trait": K.LITERATE, "chance": 0.45},
	]
