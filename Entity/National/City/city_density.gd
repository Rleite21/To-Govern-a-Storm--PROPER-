class_name CityDensity

enum Level { VERY_RURAL, RURAL, URBAN, VERY_URBANISED, METROPOLITAN }

const DISTRIBUTIONS := {
	Level.VERY_RURAL: {
		SocialClassEnums.Type.PEASANTS: 0.87,
		SocialClassEnums.Type.WORKING_CLASS: 0.02,
		SocialClassEnums.Type.MIDDLE_CLASS: 0.06,
		SocialClassEnums.Type.INDUSTRIALISTS: 0.01,
		SocialClassEnums.Type.ARISTOCRATS: 0.04,
	},
	Level.RURAL: {
		SocialClassEnums.Type.PEASANTS: 0.71,
		SocialClassEnums.Type.WORKING_CLASS: 0.08,
		SocialClassEnums.Type.MIDDLE_CLASS: 0.17,
		SocialClassEnums.Type.INDUSTRIALISTS: 0.01,
		SocialClassEnums.Type.ARISTOCRATS: 0.03,
	},
	Level.URBAN: {
		SocialClassEnums.Type.PEASANTS: 0.35,
		SocialClassEnums.Type.WORKING_CLASS: 0.31,
		SocialClassEnums.Type.MIDDLE_CLASS: 0.25,
		SocialClassEnums.Type.INDUSTRIALISTS: 0.06,
		SocialClassEnums.Type.ARISTOCRATS: 0.03,
	},
	Level.VERY_URBANISED: {
		SocialClassEnums.Type.PEASANTS: 0.12,
		SocialClassEnums.Type.WORKING_CLASS: 0.48,
		SocialClassEnums.Type.MIDDLE_CLASS: 0.32,
		SocialClassEnums.Type.INDUSTRIALISTS: 0.06,
		SocialClassEnums.Type.ARISTOCRATS: 0.02,
	},
	Level.METROPOLITAN: {
		SocialClassEnums.Type.PEASANTS: 0.07,
		SocialClassEnums.Type.WORKING_CLASS: 0.41,
		SocialClassEnums.Type.MIDDLE_CLASS: 0.44,
		SocialClassEnums.Type.INDUSTRIALISTS: 0.07,
		SocialClassEnums.Type.ARISTOCRATS: 0.01,
	},
}


static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	return Level[key] if Level.has(key) else -1


static func get_distribution(level: Level) -> Dictionary:
	return DISTRIBUTIONS[level].duplicate()
