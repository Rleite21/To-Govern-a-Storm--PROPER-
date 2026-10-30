class_name CityTabSociety
extends RefCounted


const SOCIETY_FLAGS: Array[String] = [
	"Cosmopolitan", "Militant", "Rebellious", "Secular", "Intellectual",
	"Modernist", "Provincial", "Rugged", "Traditional", "Nostalgic",
	"Clerical", "Communitarian", "Deeply Traditional", "Austere",
	"Frontier Minded", "Progressive", "Patriotic"
]


static func fill(
	data: CityData,
	society_box: Container,
	specializations_box: Container,
	traits_box: Container
) -> void:

	_fill_chips(society_box, _society_names(data.society))

	var trait_names: Array[String] = []

	for trait_type in data.traits:
		trait_names.append(
			CityTabUtils.enum_text(CityTrait.Type, trait_type)
		)

	_fill_chips(traits_box, trait_names)
	_fill_specializations(specializations_box, data)


static func _fill_chips(box: Node, names: Array[String]) -> void:
	_clear(box)

	for name in names:
		var chip := Label.new()
		chip.text = name
		box.add_child(chip)


static func _fill_specializations(box: Container, data: CityData) -> void:
	_clear(box)

	for spec in data.specializations:
		if spec == null:
			continue

		var line := Label.new()
		line.text = "%s  ×%s" % [
			CityTabUtils.enum_text(Economy.Sector, spec.sector),
			str(snappedf(spec.prevalence, 0.05))
		]

		box.add_child(line)


static func _society_names(flags: int) -> Array[String]:
	var result: Array[String] = []

	for i in range(SOCIETY_FLAGS.size()):
		if flags & (1 << i):
			result.append(SOCIETY_FLAGS[i])

	return result


static func _clear(box: Node) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
