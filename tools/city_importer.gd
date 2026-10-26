@tool
extends EditorScript

const CITIES_DIR := "res://Data/tres/Cities/"

func _run() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("Abre a cena do mapa primeiro.")
		return

	var provinces := root.find_child("Provinces", true, false)
	if provinces == null:
		push_error("Não encontrei 'Provinces' na cena '%s'." % root.name)
		return

	# Se o pai de Provinces for Node3D, as coordenadas ficam relativas a ele;
	# se for um Node simples (sem transform), usa-se o espaço global.
	var inv := Transform3D.IDENTITY
	var portugal := provinces.get_parent() as Node3D
	if portugal != null:
		inv = portugal.global_transform.affine_inverse()

	var updated := 0
	var problems := 0

	for province in provinces.get_children():
		for city in province.get_children():
			if not city is City:
				continue  # ignora a mesh da província

			var marker := _find_marker(city)
			if marker == null:
				push_warning("'%s': sem Marker3D" % city.name)
				problems += 1
				continue

			var path := CITIES_DIR + String(city.name).validate_filename() + ".tres"
			if not ResourceLoader.exists(path):
				push_warning("Sem .tres para '%s'" % city.name)
				problems += 1
				continue

			var data := ResourceLoader.load(path) as CityData
			if data == null:
				problems += 1
				continue

			data.map_position = inv * marker.global_position
			data.province_name = String(province.name)

			var err := ResourceSaver.save(data, path)
			if err != OK:
				push_error("Erro %d ao guardar %s" % [err, path])
				problems += 1
			else:
				updated += 1

	EditorInterface.get_resource_filesystem().scan()
	print("Posições atualizadas: %d, com problemas: %d" % [updated, problems])

func _find_marker(city: Node) -> Marker3D:
	for c in city.get_children():
		if c is Marker3D:
			return c
	return null
