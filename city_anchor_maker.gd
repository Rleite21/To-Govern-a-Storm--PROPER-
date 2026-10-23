@tool
extends EditorScript

const CITIES_DIR := "res://Data/tres/Cities/"
const DEBUG_LIMIT := 3  # imprime detalhes das primeiras N cidades

func _run() -> void:
	var root := get_scene()
	if root == null:
		push_error("Abre a cena do mapa primeiro.")
		return

	# find_child procura em qualquer profundidade
	var provinces := root.find_child("Provinces", true, false)
	if provinces == null:
		push_error("Não encontrei 'Provinces' na cena '%s'. Filhos diretos: %s" % [root.name, root.get_children()])
		return

	# Se o pai de Provinces for Node3D, as coordenadas ficam relativas a ele;
	# se for um Node simples (sem transform), usa-se o espaço global.
	var inv := Transform3D.IDENTITY
	var portugal := provinces.get_parent() as Node3D
	if portugal != null:
		inv = portugal.global_transform.affine_inverse()

	var updated := 0
	var problems := 0
	var debugged := 0

	for province in provinces.get_children():
		for child in province.get_children():
			if child is MeshInstance3D or not child is Node3D:
				continue  # mesh da própria província

			if debugged < DEBUG_LIMIT:
				_debug_city(child)
				debugged += 1

			var path := CITIES_DIR + String(child.name).validate_filename() + ".tres"
			if not ResourceLoader.exists(path):
				push_warning("Sem .tres para '%s'" % child.name)
				problems += 1
				continue

			var centro = _center_of_city(child, inv)
			if centro == null:
				push_warning("'%s': sem MeshInstance3D com geometria válida" % child.name)
				problems += 1
				continue

			var data := ResourceLoader.load(path) as CityData
			if data == null:
				push_warning("'%s': não consegui carregar %s como CityData" % [child.name, path])
				problems += 1
				continue

			data.map_position = centro
			data.province_name = String(province.name)
			print("%s -> centro calculado: %s" % [child.name, centro])

			var err := ResourceSaver.save(data, path)
			if err != OK:
				push_error("Erro %d ao guardar %s" % [err, path])
				problems += 1
			else:
				updated += 1
				var check := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CityData
				print("   guardado no disco: %s" % check.map_position)

	EditorInterface.get_resource_filesystem().scan()
	print("Posições atualizadas: %d, com problemas: %d" % [updated, problems])

# Centro da geometria da cidade, já em espaço do Portugal (ou global, se não houver transform).
# Junta os AABBs de todas as MeshInstance3D dentro do node da cidade.
# Devolve null se não houver nenhuma mesh válida.
func _center_of_city(city: Node3D, inv: Transform3D) -> Variant:
	var merged := AABB()
	var first := true
	for m in city.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var local_aabb := mi.get_aabb()
		if local_aabb.size == Vector3.ZERO:
			continue
		# AABB local da mesh -> espaço do Portugal
		var aabb: AABB = (inv * mi.global_transform) * local_aabb
		if first:
			merged = aabb
			first = false
		else:
			merged = merged.merge(aabb)
	if first:
		return null
	return merged.get_center()

func _debug_city(city: Node3D) -> void:
	print("--- %s (%s) ---" % [city.name, city.get_class()])
	var meshes := city.find_children("*", "MeshInstance3D", true, false)
	print("MeshInstance3D encontradas: %d" % meshes.size())
	for m in meshes:
		var mi := m as MeshInstance3D
		print("  %s | mesh: %s | aabb: %s | global_pos: %s" % [
			mi.get_path(),
			mi.mesh.get_class() if mi.mesh else "null",
			mi.get_aabb(),
			mi.global_position,
		])
