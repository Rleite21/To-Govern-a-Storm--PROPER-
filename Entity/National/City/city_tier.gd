class_name CityTier
extends RefCounted

enum Type {
	CAPITAL,
	LARGE,  
	MEDIUM,              
	SMALL,              
}

static func from_string(s: String) -> int:
	match s.strip_edges().to_lower().replace(" ", "_"):
		"CAPITAL":
			return Type.CAPITAL
		"LARGE":
			return Type.LARGE
		"MEDIUM":
			return Type.MEDIUM
		"SMALL":
			return Type.SMALL
	return -1

static func to_display_name(t: Type) -> String:
	match t:
		Type.CAPITAL: return "Capital"
		Type.LARGE: return "Large  City"
		Type.MEDIUM: return "Medium City"
		Type.SMALL: return "Small City"
	return "Unknown"
