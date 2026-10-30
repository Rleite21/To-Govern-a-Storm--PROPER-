class_name CulturalStance
extends RefCounted

enum Flag {
	NONE = 0,
	COSMOPOLITAN = 1 << 0,
	MILITANT = 1 << 1,
	REBELLIOUS = 1 << 2,
	SECULAR = 1 << 3,
	INTELLECTUAL = 1 << 4,
	MODERNIST = 1 << 5,
	PROVINCIAL = 1 << 6,
	RUGGED = 1 << 7,
	TRADITIONAL = 1 << 8,
	NOSTALGIC = 1 << 9,
	CLERICAL = 1 << 10,
	COMMUNITARIAN = 1 << 11,
	DEEPLY_TRADITIONAL = 1 << 12,
	AUSTERE = 1 << 13,
	FRONTIER_MINDED = 1 << 14,
	PROGRESSIVE = 1 << 15,
	PATRIOTIC = 1 << 16,
}

const ALIASES := { "TRADITIONALIST": "TRADITIONAL" }

var flags: int = 0

func has(flag: Flag) -> bool:
	return (flags & flag) != 0

func add(flag: Flag) -> void:
	flags |= flag

func remove(flag: Flag) -> void:
	flags &= ~flag

func get_names() -> Array[String]:
	return names_from_flags(flags)

static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	key = ALIASES.get(key, key)
	return Flag[key] if Flag.has(key) else 0

static func parse_flags(text: String) -> int:
	var result := 0
	for part in text.split(","):
		if part.strip_edges().is_empty():
			continue
		var value := from_string(part)
		if value == 0:
			push_warning("Cultural stance desconhecida: '%s'" % part.strip_edges())
			continue
		result |= value
	return result

static func names_from_flags(value: int) -> Array[String]:
	var out: Array[String] = []
	for key in Flag.keys():
		var v: int = Flag[key]
		if v != 0 and (value & v) != 0:
			out.append(key)
	return out
