class_name ClassModifiers
extends RefCounted


# Aplica todas as fontes de modifiers pela ordem certa (inicialização da cidade).
# A ordem importa: os deltas fazem clamp a cada passo e o roll consome o RNG.
static func apply_all(sc: SocialClass, city_traits: Array, density: CityDensity.Level,
		rng: RandomNumberGenerator) -> void:
	apply_city_effects(sc, city_traits)
	apply_density_effects(sc, density)
	roll_traits(sc, city_traits, density, rng)


# Aplica os efeitos dos traits da cidade (militancy/consciousness)
static func apply_city_effects(sc: SocialClass, city_traits: Array) -> void:
	ClassModsCity.apply(sc, city_traits)


# Aplica os efeitos da densidade da cidade (militancy/consciousness)
static func apply_density_effects(sc: SocialClass, density: CityDensity.Level) -> void:
	ClassModsDensity.apply(sc, density)


# Aplica o efeito de um trait de classe (chamado pelo SocialClass.add_trait)
static func apply_trait_effects(sc: SocialClass, t: SocialClassEnums.Trait) -> void:
	ClassModsTrait.apply(sc, t)


# Sorteia traits de classe a partir dos traits da cidade e da densidade
static func roll_traits(sc: SocialClass, city_traits: Array, density: CityDensity.Level,
		rng: RandomNumberGenerator, max_traits: int = 4) -> void:
	ClassTraitRolls.roll(sc, city_traits, density, rng, max_traits)
