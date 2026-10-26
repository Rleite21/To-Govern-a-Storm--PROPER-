@tool
extends EditorScript

const CITIES_DIR := "res://Data/tres/Cities/"
const CSV_PATH := "res://Data/csv files/cities.csv"

const SOCIETY_FLAGS: Array[String] = [
	"Cosmopolitan", "Militant", "Rebellious", "Secular", "Intellectual",
	"Modernist", "Provincial", "Rugged", "Traditional", "Nostalgic",
	"Clerical", "Communitarian", "Deeply Traditional", "Austere",
	"Frontier Minded", "Progressive", "Patriotic"
]

const ACCENTS := {
	"Á": "A", "À": "A", "Ã": "A", "Â": "A", "É": "E", "Ê": "E", "Í": "I",
	"Ó": "O", "Õ": "O", "Ô": "O", "Ú": "U", "Ç": "C"
}

func _run() -> void:
	var imported := _import_csv()
	print("CSV importado: %d cidades" % imported)
	_update_positions()

func _import_csv() -> int:
	if not FileAccess.file_exists(CSV_PATH):
		push_error("CSV não encontrado: %s" % CSV_PATH)
		return 0

	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("Não consegui abrir %s (erro %d)" % [CSV_PATH, FileAccess.get_open_error()])
		return 0

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CITIES_DIR))

	var header: PackedStringArray = file.get_csv_line()
	var col := {}
	for i in range(header.size()):
		col[header[i].strip_edges()] = i

	var count := 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < header.size() or row[0].strip_edges().is_empty():
			continue

		var cname: String = _field(row, col, "city_name")
		var path := CITIES_DIR + cname.validate_filename() + ".tres"

		var data: CityData = null
		if ResourceLoader.exists(path):
			data = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CityData
		if data == null:
			data = CityData.new()

		data.city_name = cname
		data.description = _field(row, col, "description")
		data.population = int(_field(row, col, "population"))
		data.society = _society_to_flags(_field(row, col, "society"), cname)

		var tier_key := _to_key(_field(row, col, "tier"))
		if CityTier.Type.has(tier_key):
			data.tier = CityTier.Type[tier_key]
		else:
			push_warning("%s: tier '%s' não existe em CityTier.Type" % [cname, tier_key])

		var density_key := _to_key(_field(row, col, "density"))
		if CityDensity.Level.has(density_key):
			data.density = CityDensity.Level[density_key]
		else:
			push_warning("%s: density '%s' não existe em CityDensity.Level" % [cname, density_key])

		data.traits.clear()
		for t in _split_list(_field(row, col, "traits")):
			var key := _to_key(t)
			if CityTrait.Type.has(key):
				data.traits.append(CityTrait.Type[key])
			else:
				push_warning("%s: trait '%s' não existe em CityTrait.Type" % [cname, key])

		var prov: String = _field(row, col, "province_name")
		if not prov.is_empty():
			data.province_name = prov

		var err := ResourceSaver.save(data, path)
		if err != OK:
			push_error("Erro %d ao guardar %s" % [err, path])
		else:
			count += 1

	file.close()
	EditorInterface.get_resource_filesystem().scan()
	return count

func _field(row: PackedStringArray, col: Dictionary, key: String) -> String:
	if not col.has(key):
		return ""
	return row[col[key]].strip_edges()

func _split_list(value: String) -> Array[String]:
	var out: Array[String] = []
	for part in value.split(","):
		var p := part.strip_edges()
		if not p.is_empty():
			out.append(p)
	return out

func _to_key(value: String) -> String:
	var s := value.strip_edges().to_upper()
	for k in ACCENTS:
		s = s.replace(k, ACCENTS[k])
	s = s.replace("&", " ").replace("-", " ")
	var parts := s.split(" ", false)
	return "_".join(parts)

func _society_to_flags(value: String, cname: String) -> int:
	var flags := 0
	for t in _split_list(value):
		var idx := SOCIETY_FLAGS.find(t)
		if idx == -1:
			push_warning("%s: society '%s' não existe nos flags" % [cname, t])
		else:
			flags |= (1 << idx)
	return flags

func _update_positions() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		push_warning("Sem cena aberta: salto a atualização de posições. Abre a cena do mapa e corre outra vez.")
		return

	var provinces := root.find_child("Provinces", true, false)
	if provinces == null:
		push_error("Não encontrei 'Provinces' na cena '%s'." % root.name)
		return

	var inv := Transform3D.IDENTITY
	var portugal := provinces.get_parent() as Node3D
	if portugal != null:
		inv = portugal.global_transform.affine_inverse()

	var updated := 0
	var problems := 0

	for province in provinces.get_children():
		for city in province.get_children():
			if not city is City:
				continue

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

			var data := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CityData
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
