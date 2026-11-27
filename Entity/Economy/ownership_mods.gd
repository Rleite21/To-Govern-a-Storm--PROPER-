class_name OwnershipMods
extends RefCounted

# Força de referência: Moderate (0.10) conta como escala 1.0
const REFERENCE_STRENGTH := 0.10
# Pontos somados ao peso de um dono que passa a poder ter ownership (provisório)
const UNLOCK_POINTS := 10.0
# Pontos somados ao peso de um dono que já tem ownership (provisório)
const BOOST_POINTS := 5.0

static var _loaded := false
static var _city_rules: Array = []
static var _class_rules: Array = []
static var _province_rules: Array = []
static var _province_blocks: Array = []


# Calcula os pontos extra de cada dono num setor, a partir dos traits da cidade,
# das classes e da província. Devolve { dono -> pontos }
static func compute(sector: Economy.Sector, base: Dictionary, city_traits: Array,
		demographics: CityDemographics, province_traits: Array) -> Dictionary:
	_ensure_loaded()
	var shifts := {}

	for rule in _city_rules:
		if rule["trait"] in city_traits:
			_add(shifts, rule, sector, base, 1.0)

	if demographics != null:
		for rule in _class_rules:
			var sc: SocialClass = demographics.social_classes.get(rule["owner"])
			if sc != null and sc.has_trait(rule["trait"]):
				_add(shifts, rule, sector, base, 1.0)

	for rule in _province_rules:
		var entry := _find_entry(province_traits, rule["cat"], rule["val"])
		if entry != null:
			_add(shifts, rule, sector, base, entry.get_multiplier() / REFERENCE_STRENGTH)

	for block in _province_blocks:
		if _find_entry(province_traits, block["cat"], block["val"]) != null:
			shifts.erase(block["owner"])

	return shifts


# Soma os pontos de uma regra, se o setor for elegível
static func _add(shifts: Dictionary, rule: Dictionary, sector: Economy.Sector,
		base: Dictionary, scale: float) -> void:
	var owner = rule["owner"]
	if rule.has("sectors"):
		if not sector in rule["sectors"]:
			return
	elif not base.has(owner):
		return
	shifts[owner] = shifts.get(owner, 0.0) + rule["points"] * scale


# Procura um trait provincial na lista de entradas (null se não existir)
static func _find_entry(entries: Array, category: int, value: int) -> ProvinceTraitEntry:
	for e in entries:
		if e != null and e.category == category and e.value == value:
			return e
	return null


# Carrega as regras uma única vez
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true

	var S := Economy.Sector
	var O := OwnershipEnums.Owner
	var K := SocialClassEnums.Trait
	var C := CityTrait.Type
	var PC := ProvinceTrait.Category
	var PS := ProvinceTrait.Social
	var PE := ProvinceTrait.Economic
	var PI := ProvinceTrait.Institutional
	var PP := ProvinceTrait.Political

	var peasant_sectors := [S.AGRICULTURE, S.FISHING]
	var working_sectors := [S.MANUFACTURING, S.HEAVY_INDUSTRY, S.MINING_RAW_MATERIALS]

	# Traits de cidade: { trait, owner, points, sectors? }
	_city_rules = [
		{"trait": C.POWERFUL_LANDOWNERS, "owner": O.ARISTOCRATS, "points": BOOST_POINTS},
		{"trait": C.POWERFUL_BOURGEOISIE, "owner": O.MIDDLE_CLASS, "points": BOOST_POINTS},
		{"trait": C.PROMINENT_GOVERNMENT_INSTITUTIONS, "owner": O.PUBLIC_COMPANIES, "points": BOOST_POINTS},
	]

	# Traits da própria classe: { trait, owner, points, sectors? }
	_class_rules = [
		{"trait": K.ORGANIZED, "owner": O.WORKING_CLASS, "points": UNLOCK_POINTS, "sectors": working_sectors},
	]

	# Traits provinciais: { cat, val, owner, points, sectors? }
	_province_rules = [
		# Desbloqueiam Peasants
		{"cat": PC.SOCIAL, "val": PS.SMALLHOLDER_AGRICULTURE, "owner": O.PEASANTS, "points": UNLOCK_POINTS, "sectors": peasant_sectors},
		{"cat": PC.SOCIAL, "val": PS.STRONG_PEASANTRY, "owner": O.PEASANTS, "points": UNLOCK_POINTS, "sectors": peasant_sectors},
		# Desbloqueiam Working Class
		{"cat": PC.SOCIAL, "val": PS.LABOUR_ORGANIZATION, "owner": O.WORKING_CLASS, "points": UNLOCK_POINTS, "sectors": working_sectors},
		{"cat": PC.POLITICAL, "val": PP.STRONG_LABOUR_MOVEMENT, "owner": O.WORKING_CLASS, "points": UNLOCK_POINTS, "sectors": working_sectors},
		# Reforçam Aristocrats
		{"cat": PC.SOCIAL, "val": PS.LARGE_LANDED_ESTATES, "owner": O.ARISTOCRATS, "points": BOOST_POINTS},
		{"cat": PC.SOCIAL, "val": PS.ENTRENCHED_ARISTOCRACY, "owner": O.ARISTOCRATS, "points": BOOST_POINTS},
		{"cat": PC.ECONOMIC, "val": PE.STRONG_LANDED_ESTATES, "owner": O.ARISTOCRATS, "points": BOOST_POINTS},
		# Reforçam Industrialists
		{"cat": PC.SOCIAL, "val": PS.POWERFUL_INDUSTRIALISTS, "owner": O.INDUSTRIALISTS, "points": BOOST_POINTS},
		{"cat": PC.ECONOMIC, "val": PE.ESTABLISHED_INDUSTRIAL_CAPITAL, "owner": O.INDUSTRIALISTS, "points": BOOST_POINTS},
		{"cat": PC.ECONOMIC, "val": PE.INDUSTRIAL_ENTREPRENEURS, "owner": O.INDUSTRIALISTS, "points": BOOST_POINTS},
		# Reforçam Middle Class
		{"cat": PC.SOCIAL, "val": PS.ESTABLISHED_BOURGEOISIE, "owner": O.MIDDLE_CLASS, "points": BOOST_POINTS},
		{"cat": PC.SOCIAL, "val": PS.WEALTHY_MERCHANT_CLASS, "owner": O.MIDDLE_CLASS, "points": BOOST_POINTS},
		{"cat": PC.ECONOMIC, "val": PE.STRONG_COMMERCIAL_CAPITAL, "owner": O.MIDDLE_CLASS, "points": BOOST_POINTS},
		{"cat": PC.ECONOMIC, "val": PE.COMMERCIAL_ENTREPRENEURS, "owner": O.MIDDLE_CLASS, "points": BOOST_POINTS},
		# Reforçam o Estado (sem efeito enquanto PUBLIC_ENABLED for false)
		{"cat": PC.INSTITUTIONAL, "val": PI.PROMINENT_GOVERNMENT_INSTITUTIONS, "owner": O.PUBLIC_COMPANIES, "points": BOOST_POINTS},
		{"cat": PC.INSTITUTIONAL, "val": PI.MAJOR_MILITARY_GARRISON, "owner": O.PUBLIC_COMPANIES, "points": BOOST_POINTS},
		{"cat": PC.INSTITUTIONAL, "val": PI.CENTRALIZED_ADMINISTRATION, "owner": O.PUBLIC_COMPANIES, "points": BOOST_POINTS},
	]

	# Traits provinciais que anulam todos os pontos de um dono
	_province_blocks = [
		{"cat": PC.SOCIAL, "val": PS.LANDLESS_PEASANTRY, "owner": O.PEASANTS},
	]
