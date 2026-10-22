@tool
extends EditorScript

const CSV_PATH := "res://Data/Cities.csv"
const OUTPUT_DIR := "res://Data/tres/Cities"
const OVERWRITE := false                    # false = não mexe em ficheiros que já existem
const REQUIRED_PROPS := ["city_name", "description", "province_name"]

func _run() -> void:
	var city_script := _find_city_script()
	if city_script == null:
		return

	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("Não consegui abrir %s (erro %d)" % [CSV_PATH, FileAccess.get_open_error()])
		return

	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	var header := file.get_csv_line()  # usado para mapear colunas pelo nome
	var col := {}
	for i in header.size():
		col[header[i].strip_edges()] = i

	var created := 0
	var skipped := 0
	var used_names := {}

	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() == 0 or (row.size() == 1 and row[0].strip_edges() == ""):
			continue  # linha vazia

		var city = city_script.new()
		city.city_name = _cell(row, col, "city_name")
		city.description = _cell(row, col, "description")
		city.province_name = _cell(row, col, "province_name")

		if city.city_name == "":
			continue

		var file_name := _to_file_name(city.city_name)
		# evita colisões se houver duas cidades com o mesmo nome
		if used_names.has(file_name):
			used_names[file_name] += 1
			file_name += "_%d" % used_names[file_name]
		else:
			used_names[file_name] = 1

		var path := "%s/%s.tres" % [OUTPUT_DIR, file_name]

		if FileAccess.file_exists(path) and not OVERWRITE:
			skipped += 1
			continue

		var err := ResourceSaver.save(city, path)
		if err == OK:
			created += 1
		else:
			push_error("Erro a guardar %s (erro %d)" % [path, err])

	EditorInterface.get_resource_filesystem().scan()
	print("Cidades criadas: %d | ignoradas (já existiam): %d" % [created, skipped])

# Encontra o script registado como CityData e confirma que tem os campos necessários
func _find_city_script() -> GDScript:
	var paths: Array[String] = []
	for entry in ProjectSettings.get_global_class_list():
		if entry["class"] == "CityData":
			paths.append(entry["path"])

	if paths.is_empty():
		push_error("Não existe nenhum script com 'class_name CityData'. Cria o city_data.gd e guarda-o.")
		return null
	if paths.size() > 1:
		push_error("Há vários scripts com class_name CityData: %s. Apaga ou renomeia os antigos." % str(paths))
		return null

	var script := load(paths[0]) as GDScript
	if script == null:
		push_error("Não consegui carregar %s (provavelmente tem erros de sintaxe)." % paths[0])
		return null

	var props := []
	for p in script.get_script_property_list():
		props.append(p["name"])
	var missing := []
	for r in REQUIRED_PROPS:
		if not props.has(r):
			missing.append(r)
	if not missing.is_empty():
		push_error("O ficheiro %s não tem estas propriedades: %s. Acrescenta '@export var <nome>: String = \"\"' para cada uma e guarda." % [paths[0], str(missing)])
		return null

	print("A usar CityData de: ", paths[0])
	return script

# Lê uma coluna pelo nome; devolve "" se a linha for curta (ex: linhas com poucas vírgulas)
func _cell(row: PackedStringArray, col: Dictionary, key: String) -> String:
	if not col.has(key) or col[key] >= row.size():
		return ""
	return row[col[key]].strip_edges()

# "Vila Franca de Xira" -> "vila_franca_de_xira", "Alcácer do Sal" -> "alcacer_do_sal"
func _to_file_name(name_in: String) -> String:
	var s := TextServerManager.get_primary_interface().strip_diacritics(name_in).to_lower()
	var out := ""
	for c in s:
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			out += c
		else:
			out += "_"
	while out.contains("__"):
		out = out.replace("__", "_")
	return out.trim_prefix("_").trim_suffix("_")
