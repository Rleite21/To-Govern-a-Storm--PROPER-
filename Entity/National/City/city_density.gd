class_name CityDensity

enum Level { VERY_RURAL, RURAL, URBAN, VERY_URBANISED, METROPOLITAN }

# Devolve -1 se não reconhecer
static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	return Level[key] if Level.has(key) else -1
