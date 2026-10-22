# sector_suitability.gd
class_name SectorSuitability

const S := Economy.Sector

const TRAIT_MULTIPLIERS := {
	"fertile_land": {
		S.AGRICULTURE: 2.0,
	},
	"coal_iron_deposits": {
		S.MINING: 3.0,
		S.HEAVY_INDUSTRY: 2.0,
	},
	"coastal_location": {
		S.FISHING: 1.0,
		S.PORTUARY: 1.0,
		S.TRADE_SERVICES: 1.1,
	},
	"established_financial_institutions": {
		S.FINANCE: 3.0,
		S.TRADE_SERVICES: 1.2,
	},
	"prominent_government_institutions": {
		S.FINANCE: 1.2,
		S.TRADE_SERVICES: 1.2,
		S.CIVIL_ENGINEERING: 1.3,
	},
	"prominent_military_bases": {
		S.ARMS: 1.0,
		S.CIVIL_ENGINEERING: 1.2,
		S.TRADE_SERVICES: 1.1,
	},
	"good_infrastructure": {
		S.TRANSPORTATION: 1.5,
		S.TRADE_SERVICES: 1.2,
		S.MANUFACTURING: 1.2,
		S.HEAVY_INDUSTRY: 1.1,
		S.CIVIL_ENGINEERING: 1.2,
	},
	"prominent_entrepreneurs": {
		S.MANUFACTURING: 1.4,
		S.TRADE_SERVICES: 1.3,
		S.HEAVY_INDUSTRY: 1.2,
		S.FINANCE: 1.2,
	},
	"bright_academia": {
		S.FINANCE: 1.2,
		S.TRADE_SERVICES: 1.2,
		S.MANUFACTURING: 1.1,
		S.CIVIL_ENGINEERING: 1.1,
	},
	"skilled_workforce": {
		S.MANUFACTURING: 1.4,
		S.HEAVY_INDUSTRY: 1.3,
		S.ARMS: 1.3,
		S.CIVIL_ENGINEERING: 1.2,
	},
	"powerful_landowners": {
		S.AGRICULTURE: 1.5,
		S.MINING: 1.2,
	},
	"provincial_crossroads": {
		S.TRANSPORTATION: 1.5,
		S.TRADE_SERVICES: 1.5,
	},
	"bureaucratic_center": {
		S.FINANCE: 1.3,
		S.TRADE_SERVICES: 1.3,
		S.CIVIL_ENGINEERING: 1.1,
	},
	"riverine_hub": {
		S.AGRICULTURE: 1.2,
		S.TRANSPORTATION: 1.3,
		S.TRADE_SERVICES: 1.2,
		S.FISHING: 1.0,
		S.PORTUARY: 1.0,
	},
	"regeneracao_blessings": {
		S.TRANSPORTATION: 1.4,
		S.CIVIL_ENGINEERING: 1.4,
		S.FINANCE: 1.2,
		S.HEAVY_INDUSTRY: 1.2,
		S.MANUFACTURING: 1.2,
		S.TRADE_SERVICES: 1.1,
	},
}

# Setor -> lista de traços; basta a cidade ter UM deles para o setor existir
const REQUIRES := {
	S.FISHING: ["coastal_location", "riverine_hub"],
	S.PORTUARY: ["coastal_location", "riverine_hub"],
	S.ARMS: ["prominent_military_bases"],
}

static func get_suitability(city_traits: Array, sector: Economy.Sector) -> float:
	if REQUIRES.has(sector):
		var allowed := false
		for t in REQUIRES[sector]:
			if city_traits.has(t):
				allowed = true
				break
		if not allowed:
			return 0.0
	var s := 1.0
	for t in city_traits:
		s *= TRAIT_MULTIPLIERS.get(t, {}).get(sector, 1.0)
	return s
