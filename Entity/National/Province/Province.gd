extends Node
class_name Province

@export var data: ProvinceData

func _ready() -> void:
	apply_visuals()  # primeiro a mesh, depois a colisão
	## Get the mesh to use for the collision shape for click detection
	for child in get_children():
		if child is MeshInstance3D and child.mesh != null:
			child.create_trimesh_collision()

func apply_visuals() -> void:
	if data == null:
		return
	for child in get_children():
		if not child is MeshInstance3D:
			continue
		if data.mesh != null:
			child.mesh = data.mesh
		if data.material != null and child.mesh != null:
			for s in child.mesh.get_surface_count():
				child.set_surface_override_material(s, data.material)
		return  # só há uma mesh por província

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
