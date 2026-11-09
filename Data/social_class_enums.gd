class_name SocialClassEnums
extends RefCounted

enum Type {
	PEASANTS,
	WORKING_CLASS,
	MIDDLE_CLASS,
	INDUSTRIALISTS,
	ARISTOCRATS,
}

enum Category { WORKING, NON_WORKING }

enum Trait {
	LITERATE,
	ILLITERATE,
	DEVOUT,
	SECULAR,
	TRADITIONALIST,
	PROGRESSIVE,
	REBELLIOUS_HISTORY,
	ORGANIZED,
	ISOLATED,
	URBANIZED,
	PATRIOTIC,
	CORRUPT_ELITES,
}

const MILITANCY_MIN := 0.0
const MILITANCY_MAX := 100.0
const CONSCIOUSNESS_MIN := 0.0
const CONSCIOUSNESS_MAX := 100.0

const WORKING_TYPES: Array[Type] = [Type.PEASANTS, Type.WORKING_CLASS]

const TYPE_NAMES := {
	Type.PEASANTS: "Peasants",
	Type.WORKING_CLASS: "Working Class",
	Type.MIDDLE_CLASS: "Middle Class",
	Type.INDUSTRIALISTS: "Industrialists",
	Type.ARISTOCRATS: "Aristocrats",
}

const TRAIT_NAMES := {
	Trait.LITERATE: "Literate",
	Trait.ILLITERATE: "Illiterate",
	Trait.DEVOUT: "Devout",
	Trait.SECULAR: "Secular",
	Trait.TRADITIONALIST: "Traditionalist",
	Trait.PROGRESSIVE: "Progressive",
	Trait.REBELLIOUS_HISTORY: "Rebellious History",
	Trait.ORGANIZED: "Organized",
	Trait.ISOLATED: "Isolated",
	Trait.URBANIZED: "Urbanized",
	Trait.PATRIOTIC: "Patriotic",
	Trait.CORRUPT_ELITES: "Corrupt Elites",
}

const CONFLICTING_TRAITS := [
	[Trait.LITERATE, Trait.ILLITERATE],
	[Trait.DEVOUT, Trait.SECULAR],
	[Trait.TRADITIONALIST, Trait.PROGRESSIVE],
]


# --- Types ---------------------------------------------------------------

static func type_to_string(type: Type) -> String:
	return TYPE_NAMES.get(type, "Unknown")


static func type_from_string(text: String) -> int:
	var key := text.strip_edges().to_upper()
	key = key.replace("&", "").replace(" ", "_").replace("-", "_")
	while key.contains("__"):
		key = key.replace("__", "_")
	if key == "PROLETARIAT":
		key = "WORKING_CLASS"
	return Type[key] if Type.has(key) else -1


static func get_category(type: Type) -> Category:
	return Category.WORKING if type in WORKING_TYPES else Category.NON_WORKING


static func is_working(type: Type) -> bool:
	return get_category(type) == Category.WORKING


# --- Traits --------------------------------------------------------------

static func trait_to_string(t: Trait) -> String:
	return TRAIT_NAMES.get(t, "Unknown")


static func trait_from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	return Trait[key] if Trait.has(key) else -1


static func traits_conflict(a: Trait, b: Trait) -> bool:
	for pair in CONFLICTING_TRAITS:
		if a in pair and b in pair and a != b:
			return true
	return false


static func random_traits(count: int, rng: RandomNumberGenerator = null) -> Array[Trait]:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var pool: Array = Trait.values()
	var result: Array[Trait] = []
	while result.size() < count and not pool.is_empty():
		var candidate: Trait = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		var ok := true
		for existing in result:
			if traits_conflict(candidate, existing):
				ok = false
				break
		if ok:
			result.append(candidate)
	return result
