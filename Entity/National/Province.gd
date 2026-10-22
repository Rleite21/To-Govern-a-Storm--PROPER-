extends Node
class_name Province

@export var data: ProvinceData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Get the mesh to use for the collision shape for click detection
	for child in get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()

func initialize() -> bool:
	if data == null:
		push_error("Province '%s' has no ProvinceData!" % name)
		return false

	data.cities.clear()  # Resources persist in memory, so avoid stale entries on re-init

	for child in get_children():
		if not child is City:
			continue
		if not child.initialize():
			continue  # City already reported its own error

		var key: String = child.data.city_name
		if data.cities.has(key):
			push_warning("Duplicate city '%s' in province '%s'" % [key, name])
		data.cities[key] = child

	if data.cities.is_empty():
		push_error("Province '%s' has no cities!" % name)
		return false

	print("-[Province Debug]- %s is good! (%d cities)" % [data.province_name, data.cities.size()])
	
	
	return true

func get_province_name() -> StringName:
	return data.province_name
	
func get_pop() -> int:
	return data.population

func get_cities() -> Dictionary[String, City]:
	return data.cities

func print_cities() -> void:
	var names := PackedStringArray(data.cities.keys())
	print("Cities of %s are: %s" % [data.province_name, ", ".join(names)])

func _process(delta: float) -> void:
	pass
