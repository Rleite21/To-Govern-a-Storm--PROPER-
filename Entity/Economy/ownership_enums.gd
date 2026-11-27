class_name OwnershipEnums
extends RefCounted

# Os valores 0 a 4 têm de coincidir com SocialClassEnums.Type
enum Owner {
	PEASANTS = 0,
	WORKING_CLASS = 1,
	MIDDLE_CLASS = 2,
	INDUSTRIALISTS = 3,
	ARISTOCRATS = 4,
	PUBLIC_COMPANIES = 5,  # placeholder temporário
}

# Classes que podem ter ownership fora da sua cidade
const EXTERNAL_OWNERS: Array[Owner] = [Owner.INDUSTRIALISTS, Owner.ARISTOCRATS]

const NAMES := {
	Owner.PEASANTS: "Peasants",
	Owner.WORKING_CLASS: "Working Class",
	Owner.MIDDLE_CLASS: "Middle Class",
	Owner.INDUSTRIALISTS: "Industrialists",
	Owner.ARISTOCRATS: "Aristocrats",
	Owner.PUBLIC_COMPANIES: "Public Companies",
}


# Converte uma classe social no dono correspondente
static func from_class(t: SocialClassEnums.Type) -> Owner:
	return int(t) as Owner


# Converte um dono na classe social correspondente (-1 se não for uma classe)
static func to_class(o: Owner) -> int:
	return int(o) if is_social_class(o) else -1


# True se o dono é uma classe social (e não as public companies)
static func is_social_class(o: Owner) -> bool:
	return o != Owner.PUBLIC_COMPANIES


# True se este dono pode ter ownership fora da sua cidade
static func can_own_external(o: Owner) -> bool:
	return o in EXTERNAL_OWNERS


# Nome do dono para mostrar na UI
static func display_name(o: Owner) -> String:
	return NAMES.get(o, "Unknown")
