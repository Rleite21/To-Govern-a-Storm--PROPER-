class_name CityTier
extends RefCounted

enum Type {
	CAPITAL,             # Lisboa
	PROVINCIAL_CAPITAL,  # capital de província
	MEDIUM,              # cidade média
	SMALL,               # pequena
}

static func from_string(s: String) -> int:
	match s.strip_edges().to_lower().replace(" ", "_"):
		"capital":
			return Type.CAPITAL
		"provincial_capital", "capital_provincia", "capital_de_provincia":
			return Type.PROVINCIAL_CAPITAL
		"medium", "media", "média", "cidade_media", "cidade_média":
			return Type.MEDIUM
		"small", "pequena":
			return Type.SMALL
	return -1

static func to_display_name(t: Type) -> String:
	match t:
		Type.CAPITAL: return "Capital"
		Type.PROVINCIAL_CAPITAL: return "Provincial Capital"
		Type.MEDIUM: return "Medium City"
		Type.SMALL: return "Small City"
	return "Unknown"
