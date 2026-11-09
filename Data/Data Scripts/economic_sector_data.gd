class_name EconomicSectorData
extends Resource

@export_group("Identification")
@export var sector: EconomyEnums.Sector

@export_group("Base Statistics")
@export var baseline_weight: float = 0.0 # baseline weight to calculate the size within a city
@export var base_strength: float = 1.0 # resillience to crisis 

@export_group("Labour Requirements")
# Amount of workers per unit of size of a given social class
@export var required_labour: Dictionary[SocialClass.Type, float] = {}

@export_group("Production & Distribution")
# Amount of products made per unit of size
@export var production: Dictionary = {}
@export var sector_type: EconomyEnums.Sector_Type
@export var required_raw_materials: Dictionary[EconomyEnums.Sector, float] = {}
@export var distribution_cost_per_unit: float = 1.0


@export_group("Sector Interactions")
# From which sectors does this one sell and at what rates
@export var preferred_customers: Dictionary[EconomyEnums.Sector, float] = {}

@export_group("Growth")
@export var growth_rate: float = 0.01
@export var decay_rate: float = 0.01
