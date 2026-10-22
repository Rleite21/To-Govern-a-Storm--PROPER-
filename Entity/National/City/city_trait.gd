class_name CityTrait

# Acrescentar novos sempre no FIM (o .tres grava o número)
enum Type {
	FERTILE_LAND, COAL_AND_IRON_DEPOSITS, COASTAL_LOCATION,
	ESTABLISHED_FINANCIAL_INSTITUTIONS, PROMINENT_GOVERNMENT_INSTITUTIONS,
	PROMINENT_MILITARY_BASES, GOOD_INFRASTRUCTURE, PROMINENT_ENTREPRENEURS,
	BRIGHT_ACADEMIA, SKILLED_WORKFORCE, POWERFUL_LANDOWNERS,
	PROVINCIAL_CROSSROADS, BUREAUCRATIC_CENTER, RIVERINE_HUB,
	REGENERACAO_BLESSINGS,
}

# Nomes do CSV que não batem com o enum
const ALIASES := {
	"STRONG_RIVERIN_HUB": "RIVERINE_HUB",
	"BLESSINGS_OF_THE_REGENERAÇÃO": "REGENERACAO_BLESSINGS",
	"BLESSINGS_OF_THE_REGENERACAO": "REGENERACAO_BLESSINGS",
}

# Devolve -1 se não reconhecer
static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	key = ALIASES.get(key, key)
	return Type[key] if Type.has(key) else -1
