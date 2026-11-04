class_name Economy

enum Sector {
	AGRICULTURE, HEAVY_INDUSTRY, FINANCE, TRANSPORTATION, MINING_RAW_MATERIALS,
	TRADE_SERVICES, ARMS_INDUSTRY, MANUFACTURING, FISHING, PORTUARY, CIVIL_ENGINEERING
}

# Valores provisórios, a afinar nos testes
const BASELINE_WEIGHT := {
	Sector.AGRICULTURE: 0.8,
	Sector.HEAVY_INDUSTRY: 0.25,
	Sector.FINANCE: 0.15,
	Sector.TRANSPORTATION: 0.25,
	Sector.MINING_RAW_MATERIALS: 0.2,
	Sector.TRADE_SERVICES: 0.5,
	Sector.ARMS_INDUSTRY: 0.1,
	Sector.MANUFACTURING: 0.4,
	Sector.FISHING: 0.1,
	Sector.PORTUARY: 0.1,
	Sector.CIVIL_ENGINEERING: 0.15,
}

static func display_name(type: int) -> String:
	match type:
		Sector.AGRICULTURE:
			return "Agriculture"
		Sector.HEAVY_INDUSTRY:
			return "Heavy Industry"
		Sector.FINANCE:
			return "Finance"
		Sector.TRANSPORTATION:
			return "Transportation"
		Sector.MINING_RAW_MATERIALS:
			return "Mining & Raw Materials"
		Sector.TRADE_SERVICES:
			return "Trade & Services"
		Sector.ARMS_INDUSTRY:
			return "Arms Industry"
		Sector.MANUFACTURING:
			return "Manufacturing"
		Sector.FISHING:
			return "Fishing"
		Sector.PORTUARY:
			return "Portuary"
		Sector.CIVIL_ENGINEERING:
			return "Civil Engineering"
	return "Unknown"


static func economic_scale(total_population: float) -> float:
	return 100.0 * pow(total_population / 10000.0, 0.8)

static func base_size(pop: float, sector: Sector, suitability: float) -> float:
	return economic_scale(pop) * BASELINE_WEIGHT[sector] * suitability

static func size_potential(pop: float, sector: Sector, suitability: float, prevalence: float) -> float:
	return base_size(pop, sector, suitability) * prevalence

static func roll_size(pop: float, sector: Sector, suitability: float, prevalence: float, rng: RandomNumberGenerator = null) -> float:
	var lo := base_size(pop, sector, suitability)
	var hi := size_potential(pop, sector, suitability, prevalence)
	if rng == null:
		return randf_range(lo, hi)
	return rng.randf_range(lo, hi)
