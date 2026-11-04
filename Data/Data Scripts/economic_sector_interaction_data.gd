class_name EconomicSectorInteractionData
extends Resource


@export var target_sector: EconomyEnums.Sector

@export_range(0.0, 1.0, 0.01)
var demand_weight: float = 1.0

@export var can_buy: bool = true
@export var can_sell: bool = true
