class_name SocialClass
extends RefCounted

static var _templates: Dictionary = {}

var type: SocialClassEnums.Type
var population: int = 0
var population_share: float = 0.0
var convictions: Dictionary = {}
var traits: Array[SocialClassEnums.Trait] = []
var wealth: float = 0.0

var militancy: float = 0.0:
	set(value):
		militancy = clampf(value, SocialClassEnums.MILITANCY_MIN, SocialClassEnums.MILITANCY_MAX)

var consciousness: float = 0.0:
	set(value):
		consciousness = clampf(value, SocialClassEnums.CONSCIOUSNESS_MIN, SocialClassEnums.CONSCIOUSNESS_MAX)

var is_working: bool:
	get: return SocialClassEnums.is_working(type)


func _init(p_type := SocialClassEnums.Type.PEASANTS) -> void:
	type = p_type


# --- Templates -----------------------------------------------------------

static func get_template(p_type: SocialClassEnums.Type) -> SocialClassTemplate:
	if _templates.is_empty():
		_templates = {
			SocialClassEnums.Type.PEASANTS: load("res://Data/tres/Social Classes/Peasants.tres"),
			SocialClassEnums.Type.WORKING_CLASS: load("res://Data/tres/Social Classes/Working_Class.tres"),
			SocialClassEnums.Type.MIDDLE_CLASS: load("res://Data/tres/Social Classes/Middle_Class.tres"),
			SocialClassEnums.Type.INDUSTRIALISTS: load("res://Data/tres/Social Classes/Industrialists.tres"),
			SocialClassEnums.Type.ARISTOCRATS: load("res://Data/tres/Social Classes/Aristocrats.tres"),
		}
		for key in _templates:
			assert(_templates[key].type == key, "Template type mismatch for %s" % key)
	return _templates[p_type]


# --- Factory -------------------------------------------------------------

static func create(p_type: SocialClassEnums.Type, rng: RandomNumberGenerator) -> SocialClass:
	return from_template(get_template(p_type), rng)


static func from_template(template: SocialClassTemplate, rng: RandomNumberGenerator) -> SocialClass:
	var sc := SocialClass.new(template.type)
	sc.militancy = template.base_militancy + rng.randf_range(-template.militancy_noise, template.militancy_noise)
	sc.consciousness = template.base_consciousness + rng.randf_range(-template.consciousness_noise, template.consciousness_noise)
	sc.convictions = template.convictions.duplicate(true)
	sc.traits.assign(template.default_traits)
	return sc


# --- Modifiers -----------------------------------------------------------

func apply_modifier(militancy_delta: float = 0.0, consciousness_delta: float = 0.0) -> void:
	militancy += militancy_delta
	consciousness += consciousness_delta


func add_trait(t: SocialClassEnums.Trait, apply_effects: bool = true) -> bool:
	if has_trait(t):
		return false
	for existing in traits:
		if SocialClassEnums.traits_conflict(t, existing):
			return false
	if not SocialClassEnums.Trait.values().has(t):
		push_error("Trait inválido a ser adicionado: %s (classe %s)" % [t, SocialClassEnums.type_to_string(type)])
		print_stack()
		return false
	traits.append(t)
	if apply_effects:
		ClassModifiers.apply_trait_effects(self, t)
	return true


func set_population(total_city_population: int, share: float) -> void:
	population_share = share
	population = roundi(total_city_population * share)


# --- Queries -------------------------------------------------------------

func get_display_name() -> String:
	return SocialClassEnums.type_to_string(type)


func has_trait(t: SocialClassEnums.Trait) -> bool:
	return t in traits
