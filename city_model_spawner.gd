extends Node

const MIN_CLICK_SIZE := Vector3(0.15, 0.15, 0.15)

@export var model_set: CityModelSet
@export var model_y_offset := 0.0
## Gera uma colisão em caixa se o .glb não trouxer uma (precisa para os cliques)
@export var generate_click_body := true
## Anula a escala herdada dos nós pai (City/Province/Marker), para todos os modelos ficarem com o mesmo tamanho
@export var normalize_scale := true
## Multiplicador extra de tamanho para todos os modelos
@export var model_scale := 1.0
## Imprime uma linha por cidade
@export var verbose := false

@onready var provinces := get_parent().get_node_or_null("Provinces")
@onready var map_root := get_parent() as Node3D

func _ready() -> void:
	spawn()

func spawn() -> void:
	if provinces == null or model_set == null:
		push_error("CityModelSpawner: falta o node Provinces (%s) ou o Model Set (%s)." % [provinces, model_set])
		return

	var found := 0
	var spawned := 0
	var stale := 0
	var odd_scale := 0
	var skipped: Array[String] = []

	var reference_scale := Vector3.ONE
	if map_root != null:
		reference_scale = map_root.global_transform.basis.get_scale()

	for province in provinces.get_children():
		for city in province.get_children():
			if not city is City:
				continue  # ignora a mesh da província
			found += 1

			var marker := _find_marker(city)
			var data := _get_data(city)
			if marker == null or data == null:
				var why := "sem Marker3D" if marker == null else "sem CityData"
				_skip(skipped, city, province, why)
				continue

			if city.data != data:
				stale += 1
				city.data = data

			var scene := model_set.get_scene(data.tier)
			if scene == null:
				_skip(skipped, city, province, "sem modelo para o tier %s" % data.tier)
				continue

			_clear_previous(marker)

			# map_position é relativa à raiz do mapa, por isso converte para global
			if map_root != null:
				marker.global_position = map_root.to_global(data.map_position)
			else:
				marker.global_position = data.map_position

			# Diagnóstico de escala herdada
			var marker_scale := marker.global_transform.basis.get_scale()
			if not marker_scale.is_equal_approx(reference_scale):
				odd_scale += 1
				print("[Spawner][ESCALA] '%s' (%s): escala global do marker %s (esperado %s) | marker local %s | city %s | provincia %s" % [
					city.name, province.name, marker_scale, reference_scale,
					marker.scale, (city as Node3D).scale, (province as Node3D).scale if province is Node3D else "n/a"
				])

			var model := scene.instantiate() as Node3D
			if model == null:
				_skip(skipped, city, province, "a cena do tier %s não tem raiz Node3D" % data.tier)
				continue
			model.name = "Model"
			marker.add_child(model)

			if normalize_scale:
				# Escala final no mundo = escala do mapa, independente dos pais
				model.scale = (reference_scale / marker_scale) * model_scale
				model.position.y = model_y_offset / maxf(marker_scale.y, 0.0001)
			else:
				model.scale = Vector3.ONE * model_scale
				model.position.y = model_y_offset

			if generate_click_body and model.find_children("*", "CollisionObject3D", true, false).is_empty():
				_add_click_body(marker, model)

			spawned += 1

			if verbose:
				print("[Spawner] %s (%s) tier=%s pos=%s" % [city.name, province.name, data.tier, marker.global_position])

	print("[CityModelSpawner] Cidades: %d | Models spawned: %d | Data desatualizado: %d | Escala estranha: %d | Saltadas: %d" % [found, spawned, stale, odd_scale, skipped.size()])
	for s in skipped:
		print("   - ", s)

func _skip(list: Array[String], city: Node, province: Node, reason: String) -> void:
	var msg := "%s (%s): %s" % [city.name, province.name, reason]
	list.append(msg)
	push_warning("CityModelSpawner: " + msg)

func _clear_previous(marker: Marker3D) -> void:
	for child_name in ["Model", "ClickBody"]:
		var old := marker.get_node_or_null(child_name)
		if old != null:
			marker.remove_child(old)
			old.queue_free()

func _find_marker(city: Node) -> Marker3D:
	for c in city.get_children():
		if c is Marker3D:
			return c
	return null

# O .tres é a fonte de verdade. O data guardado na cena só serve de fallback.
func _get_data(city: City) -> CityData:
	var path := CityUtils.city_path(String(city.name))
	if ResourceLoader.exists(path):
		var loaded := load(path) as CityData
		if loaded != null:
			return loaded
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
