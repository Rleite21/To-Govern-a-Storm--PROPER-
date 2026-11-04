class_name CityDensity

enum Level { VERY_RURAL, RURAL, URBAN, VERY_URBANISED, METROPOLITAN }

const DISTRIBUTIONS := {
	Level.VERY_RURAL: {
		SocialClass.Type.PEASANTS: 0.87,
		SocialClass.Type.WORKING_CLASS: 0.02,
		SocialClass.Type.MIDDLE_CLASS: 0.06,
		SocialClass.Type.INDUSTRIALISTS: 0.01,
		SocialClass.Type.ARISTOCRATS: 0.04,
	},
	Level.RURAL: {
		SocialClass.Type.PEASANTS: 0.71,
		SocialClass.Type.WORKING_CLASS: 0.08,
		SocialClass.Type.MIDDLE_CLASS: 0.17,
		SocialClass.Type.INDUSTRIALISTS: 0.01,
		SocialClass.Type.ARISTOCRATS: 0.03,
	},
	Level.URBAN: {
		SocialClass.Type.PEASANTS: 0.35,
		SocialClass.Type.WORKING_CLASS: 0.31,
		SocialClass.Type.MIDDLE_CLASS: 0.25,
		SocialClass.Type.INDUSTRIALISTS: 0.06,
		SocialClass.Type.ARISTOCRATS: 0.03,
	},
	Level.VERY_URBANISED: {
		SocialClass.Type.PEASANTS: 0.12,
		SocialClass.Type.WORKING_CLASS: 0.48,
		SocialClass.Type.MIDDLE_CLASS: 0.32,
		SocialClass.Type.INDUSTRIALISTS: 0.06,
		SocialClass.Type.ARISTOCRATS: 0.02,
	},
	Level.METROPOLITAN: {
		SocialClass.Type.PEASANTS: 0.07,
		SocialClass.Type.WORKING_CLASS: 0.41,
		SocialClass.Type.MIDDLE_CLASS: 0.44,
		SocialClass.Type.INDUSTRIALISTS: 0.07,
		SocialClass.Type.ARISTOCRATS: 0.01,
	},
}

static func from_string(text: String) -> int:
	var key := text.strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	return Level[key] if Level.has(key) else -1

static func get_distribution(level: Level) -> Dictionary:
	return DISTRIBUTIONS[level].duplicate()

static func create_social_classes(level: Level) -> Array[SocialClass]:
	var result: Array[SocialClass] = []
	for class_type in DISTRIBUTIONS[level]:
		result.append(SocialClass.new(class_type, DISTRIBUTIONS[level][class_type]))
	return result
