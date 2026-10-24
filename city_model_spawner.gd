extends Node

const CITIES_DIR := "res://Data/tres/Cities/"
const MIN_CLICK_SIZE := Vector3(0.15, 0.15, 0.15)

@export var model_set: CityModelSet
@export var model_y_offset := 0.0
## Gera uma colisão em caixa se o .glb não trouxer uma (precisa para os cliques)
@export var generate_click_body := true

@onready var provinces := get_parent().get_node_or_null("Provinces")

func _ready() -> void:
	spawn()

func spawn() -> void:
	if provinces == null or model_set == null:
		push_error("CityModelSpawner: falta o node Provinces ou o Model Set.")
		return

	var spawned := 0
	for province in provinces.get_children():
		for city in province.get_children():
			if not city is City:
				continue  # ignora a mesh da província

			var marker := _find_marker(city)
			var data := _get_data(city)
			if marker == null or data == null:
				push_warning("'%s': sem Marker3D ou CityData" % city.name)
				continue

			var scene := model_set.get_scene(data.tier)
			if scene == null:
				push_warning("'%s': sem modelo para o tier" % city.name)
				continue

			marker.global_position = data.map_position  # o .tres é a fonte da coordenada

			var model := scene.instantiate() as Node3D
			model.name = "Model"
			model.position.y = model_y_offset
			marker.add_child(model)

			if generate_click_body and model.find_children("*", "CollisionObject3D", true, false).is_empty():
				_add_click_body(marker, model)
			spawned += 1

	print("[CityModelSpawner] Models spawned: %d" % spawned)

func _find_marker(city: Node) -> Marker3D:
	for c in city.get_children():
		if c is Marker3D:
			return c
	return null

func _get_data(city: City) -> CityData:
	if city.data != null:
		return city.data
	var path := CITIES_DIR + String(city.name).validate_filename() + ".tres"
	if ResourceLoader.exists(path):
		city.data = load(path) as CityData
	return city.data

func _add_click_body(marker: Marker3D, model: Node3D) -> void:
	var to_marker := marker.global_transform.affine_inverse()
	var merged := AABB()
	var first := true
	for m in model.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var a: AABB = (to_marker * mi.global_transform) * mi.get_aabb()
		merged = a if first else merged.merge(a)
		first = false
	if first:
		return

	var body := StaticBody3D.new()
	body.name = "ClickBody"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = merged.size.max(MIN_CLICK_SIZE)
	shape.shape = box
	shape.position = merged.get_center()
	body.add_child(shape)
	marker.add_child(body)
