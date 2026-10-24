@tool
extends EditorScript

const CITIES_DIR := "res://Data/tres/Cities/"

func _run() -> void:
	var root := get_scene() as Node3D
	if root == null:
		push_error("Abre a cena do mapa primeiro.")
		return

	var provinces := root.find_child("Provinces", true, false)
	if provinces == null:
		push_error("Não encontrei 'Provinces' na cena '%s'." % root.name)
		return

	# Coordenadas relativas ao Portugal (pai do Provinces)
	var portugal := provinces.get_parent() as Node3D
	var inv := portugal.global_transform.affine_inverse()

	var updated := 0
	var missing := 0

	for province in provinces.get_children():
		for child in province.get_children():
			if child is MeshInstance3D or not child is Node3D:
				continue  # mesh da própria província

			var mesh_node := _find_mesh(child)
			if mesh_node == null:
				push_warning("'%s' não tem MeshInstance3D filha" % child.name)
				missing += 1
				continue

			var path := CITIES_DIR + String(child.name).validate_filename() + ".tres"
			if not ResourceLoader.exists(path):
				push_warning("Sem .tres para '%s'" % child.name)
				missing += 1
				continue

			var data := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CityData
			if data == null:
				continue

			data.map_position = inv * mesh_node.global_position
			data.province_name = String(province.name)

			var err := ResourceSaver.save(data, path)
			if err != OK:
				push_error("Erro %d ao guardar %s" % [err, path])
			else:
				updated += 1

	EditorInterface.get_resource_filesystem().scan()
	print("Posições atualizadas: %d, com problemas: %d" % [updated, missing])

# Primeira MeshInstance3D encontrada dentro do node da cidade (em qualquer profundidade)
func _find_mesh(node: Node) -> MeshInstance3D:
	for c in node.find_children("*", "MeshInstance3D", true, false):
		return c as MeshInstance3D
	return null
