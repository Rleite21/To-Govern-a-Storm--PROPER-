class_name OwnershipTable
extends RefCounted

static var _loaded := false
static var _base: Dictionary = {}


# Devolve a ownership base de um setor (pontos por dono, soma 100)
static func get_base(sector: Economy.Sector) -> Dictionary:
	_ensure_loaded()
	return _base.get(sector, {}).duplicate()


# Carrega a tabela uma única vez (valores provisórios)
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var S := Economy.Sector
	var O := OwnershipEnums.Owner

	# Setor -> { dono -> pontos }. Peasants e Working Class ficam a 0 (omitidos)
	_base = {
		S.AGRICULTURE: {O.MIDDLE_CLASS: 10.0, O.INDUSTRIALISTS: 5.0, O.ARISTOCRATS: 80.0, O.PUBLIC_COMPANIES: 5.0},
		S.HEAVY_INDUSTRY: {O.MIDDLE_CLASS: 10.0, O.INDUSTRIALISTS: 65.0, O.ARISTOCRATS: 10.0, O.PUBLIC_COMPANIES: 15.0},
		S.FINANCE: {O.MIDDLE_CLASS: 25.0, O.INDUSTRIALISTS: 35.0, O.ARISTOCRATS: 30.0, O.PUBLIC_COMPANIES: 10.0},
		S.TRANSPORTATION: {O.MIDDLE_CLASS: 10.0, O.INDUSTRIALISTS: 40.0, O.ARISTOCRATS: 10.0, O.PUBLIC_COMPANIES: 40.0},
		S.MINING_RAW_MATERIALS: {O.MIDDLE_CLASS: 5.0, O.INDUSTRIALISTS: 45.0, O.ARISTOCRATS: 40.0, O.PUBLIC_COMPANIES: 10.0},
		S.TRADE_SERVICES: {O.MIDDLE_CLASS: 75.0, O.INDUSTRIALISTS: 15.0, O.ARISTOCRATS: 10.0},
		S.ARMS_INDUSTRY: {O.INDUSTRIALISTS: 25.0, O.ARISTOCRATS: 10.0, O.PUBLIC_COMPANIES: 65.0},
		S.MANUFACTURING: {O.MIDDLE_CLASS: 40.0, O.INDUSTRIALISTS: 50.0, O.ARISTOCRATS: 10.0},
		S.FISHING: {O.MIDDLE_CLASS: 50.0, O.INDUSTRIALISTS: 20.0, O.ARISTOCRATS: 20.0, O.PUBLIC_COMPANIES: 10.0},
		S.PORTUARY: {O.MIDDLE_CLASS: 15.0, O.INDUSTRIALISTS: 35.0, O.ARISTOCRATS: 10.0, O.PUBLIC_COMPANIES: 40.0},
		S.CIVIL_ENGINEERING: {O.MIDDLE_CLASS: 35.0, O.INDUSTRIALISTS: 40.0, O.ARISTOCRATS: 5.0, O.PUBLIC_COMPANIES: 20.0},
	}
