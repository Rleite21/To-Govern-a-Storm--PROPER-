class_name SectorOwnership
extends RefCounted

# Quando as public companies existirem, passa a true
const PUBLIC_ENABLED := false
# Variação aleatória de cada parcela (±15%)
const NOISE := 0.15
# Percentagem da população a partir da qual uma classe conta por inteiro como dona
const PRESENCE_FULL := 0.02


# Gera a ownership inicial de um setor: tabela base + pontos dos traits (shifts),
# ruído, presença da classe e normalização para somar 1.0. Devolve { dono -> fração }
static func generate(sector: Economy.Sector, demographics: CityDemographics,
		rng: RandomNumberGenerator, shifts: Dictionary = {}) -> Dictionary:
	var base := OwnershipTable.get_base(sector)
	var weights := {}
	var total := 0.0

	# Ordem fixa dos donos, e um valor de RNG por dono sempre consumido,
	# para a seed ser reprodutível independentemente dos traits
	for owner in OwnershipEnums.Owner.values():
		var noise := 1.0 + rng.randf_range(-NOISE, NOISE)

		if owner == OwnershipEnums.Owner.PUBLIC_COMPANIES and not PUBLIC_ENABLED:
			continue

		var points: float = base.get(owner, 0.0) + shifts.get(owner, 0.0)
		if points <= 0.0:
			continue

		var w: float = points * noise
		if OwnershipEnums.is_social_class(owner):
			w *= _presence(owner, demographics)
		if w <= 0.0:
			continue

		weights[owner] = w
		total += w

	if total <= 0.0:
		return _fallback(demographics)

	var result := {}
	for owner in weights:
		result[owner] = weights[owner] / total
	return result


# Fator de 0 a 1 que reduz o peso de classes com pouca população na cidade
static func _presence(owner: OwnershipEnums.Owner, demographics: CityDemographics) -> float:
	if demographics == null:
		return 1.0
	var share := demographics.get_class_share(int(owner) as SocialClassEnums.Type)
	return clampf(share / PRESENCE_FULL, 0.0, 1.0)


# Se nenhuma classe tem presença, a classe mais populosa fica com tudo
static func _fallback(demographics: CityDemographics) -> Dictionary:
	if demographics == null or demographics.social_classes.is_empty():
		return {}
	var best = null
	for type in demographics.social_classes:
		if best == null or demographics.social_classes[type].population > demographics.social_classes[best].population:
			best = type
	return {OwnershipEnums.from_class(best): 1.0}
