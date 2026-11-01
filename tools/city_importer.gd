@tool
extends EditorScript

const CSV_PATH := "res://Data/csv files/cities.csv"

# Colunas que têm de existir no CSV (province_name é opcional)
const REQUIRED_COLUMNS: Array[String] = [
	"city_name", "description", "population",
	"society", "tier", "density", "traits"
]

# Peso dado a todos os setores listados na coluna "economy"
const DEFAULT_PREVALENCE := 1.0

const SOCIETY_FLAGS: Array[String] = [
	"Cosmopolitan", "Militant", "Rebellious", "Secular", "Intellectual",
	"Modernist", "Provincial", "Rugged", "Traditional", "Nostalgic",
	"Clerical", "Communitarian", "Deeply Traditional", "Austere",
	"Frontier Minded", "Progressive", "Patriotic"
]

const ACCENTS := {
	"Á": "A", "À": "A", "Ã": "A", "Â": "A",
	"É": "E", "Ê": "E",
	"Í": "I",
	"Ó": "O", "Õ": "O", "Ô": "O",
	"Ú": "U",
	"Ç": "C"
}

# Contadores globais desta execução
var _warnings := 0
var _errors := 0

# path do .tres -> nome da cidade no CSV (para cruzar com a cena)
var _csv_paths := {}


func _run() -> void:
	_warnings = 0
	_errors = 0
	_csv_paths.clear()

	print("")
	print("================ IMPORT DE CIDADES ================")

	var imported := _import_csv()
	_update_positions()

	print("")
	print("================ RESUMO FINAL =====================")
	print("Cidades importadas: %d" % imported)
	print("Avisos:  %d" % _warnings)
	print("Erros:   %d" % _errors)
	if _warnings == 0 and _errors == 0:
		print("Tudo OK.")
	else:
		print("Procura por [AVISO] e [ERRO] acima para ver os detalhes.")
	print("===================================================")


# --------------------------------------------------
# LOG HELPERS
# --------------------------------------------------

func _warn(msg: String) -> void:
	_warnings += 1
	print("[AVISO] ", msg)
	push_warning(msg)


func _err(msg: String) -> void:
	_errors += 1
	print("[ERRO] ", msg)
	push_error(msg)


# --------------------------------------------------
# CSV IMPORT
# --------------------------------------------------

func _import_csv() -> int:
	print("")
	print("--- A importar CSV: %s" % CSV_PATH)

	if not FileAccess.file_exists(CSV_PATH):
		_err("CSV não encontrado: %s (confirma o caminho e a pasta 'csv files')" % CSV_PATH)
		return 0

	var file := FileAccess.open(CSV_PATH, FileAccess.READ)

	if file == null:
		var open_err := FileAccess.get_open_error()
		_err(
			"Não consegui abrir %s (erro %d: %s)"
			% [CSV_PATH, open_err, error_string(open_err)]
		)
		return 0

	var dir_err := DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(CityUtils.CITIES_DIR)
	)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		_err(
			"Não consegui criar a pasta %s (erro %d: %s)"
			% [CityUtils.CITIES_DIR, dir_err, error_string(dir_err)]
		)

	var header: PackedStringArray = file.get_csv_line()
	var col := {}

	for i in range(header.size()):
		col[header[i].strip_edges()] = i

	print("Colunas encontradas (%d): %s" % [col.size(), ", ".join(col.keys())])

	# Colunas obrigatórias
	var missing_cols: Array[String] = []
	for rc in REQUIRED_COLUMNS:
		if not col.has(rc):
			missing_cols.append(rc)

	if not missing_cols.is_empty():
		_err(
			"Faltam colunas obrigatórias no CSV: %s. "
			% ", ".join(missing_cols)
			+ "Verifica ortografia, espaços e se o separador é vírgula."
		)
		if header.size() <= 1:
			_err(
				"O cabeçalho só tem %d coluna. O CSV pode estar a usar ';' em vez de ','."
				% header.size()
			)

	if not col.has("province_name"):
		print("[INFO] Sem coluna 'province_name' no CSV (opcional, vem da cena do mapa).")

	if not col.has("economy"):
		print("[INFO] Sem coluna 'economy' no CSV: as specializations não são alteradas.")

	var count := 0
	var problems := 0
	var skipped := 0
	var line_no := 1  # cabeçalho é a linha 1
	var seen_names := {}

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		line_no += 1

		# Linha vazia no fim do ficheiro
		if row.size() == 0 or (row.size() == 1 and row[0].strip_edges().is_empty()):
			continue

		if row.size() < header.size():
			_warn(
				"Linha %d ignorada: tem %d colunas e o cabeçalho tem %d (conteúdo: '%s')"
				% [line_no, row.size(), header.size(), ",".join(row).left(60)]
			)
			skipped += 1
			continue

		if row[0].strip_edges().is_empty():
			_warn("Linha %d ignorada: primeira coluna vazia." % line_no)
			skipped += 1
			continue

		var cname := _field(row, col, "city_name")

		if cname.is_empty():
			_warn("Linha %d ignorada: 'city_name' vazio." % line_no)
			skipped += 1
			continue

		if seen_names.has(cname):
			_warn(
				"Linha %d: cidade '%s' duplicada (já apareceu na linha %d). A última sobrepõe a anterior."
				% [line_no, cname, seen_names[cname]]
			)
		seen_names[cname] = line_no

		var path := CityUtils.city_path(cname)
		_csv_paths[path] = cname

		var data: CityData = null

		if ResourceLoader.exists(path):
			data = ResourceLoader.load(
				path,
				"",
				ResourceLoader.CACHE_MODE_IGNORE
			) as CityData

			if data == null:
				_warn(
					"%s (linha %d): o ficheiro %s existe mas não é um CityData válido. Vai ser recriado."
					% [cname, line_no, path]
				)

		if data == null:
			data = CityData.new()

		# Basic information
		data.city_name = cname
		data.description = _field(row, col, "description")

		if data.description.is_empty():
			_warn("%s (linha %d): descrição vazia." % [cname, line_no])

		var pop_text := _field(row, col, "population").replace(" ", "")
		if pop_text.is_valid_int():
			data.population = int(pop_text)
			if data.population <= 0:
				_warn(
					"%s (linha %d): população é %d (as classes sociais vão ficar vazias)."
					% [cname, line_no, data.population]
				)
		else:
			_warn(
				"%s (linha %d): população '%s' não é um número inteiro. Ficou a 0."
				% [cname, line_no, pop_text]
			)
			data.population = 0

		# Society
		data.society = _society_to_flags(
			_field(row, col, "society"),
			cname,
			line_no
		)

		# Tier
		var tier_raw := _field(row, col, "tier")
		var tier_key := _to_key(tier_raw)

		if CityTier.Type.has(tier_key):
			data.tier = CityTier.Type[tier_key]
		else:
			_warn(
				"%s (linha %d): tier '%s' (chave '%s') não existe. Válidos: %s"
				% [cname, line_no, tier_raw, tier_key, ", ".join(CityTier.Type.keys())]
			)

		# Density
		var density_raw := _field(row, col, "density")
		var density_key := _to_key(density_raw)

		if CityDensity.Level.has(density_key):
			data.density = CityDensity.Level[density_key]
		else:
			_warn(
				"%s (linha %d): density '%s' (chave '%s') não existe. Válidos: %s"
				% [cname, line_no, density_raw, density_key, ", ".join(CityDensity.Level.keys())]
			)

		# Traits (array novo em vez de clear(), evita "Array is in read-only state")
		var new_traits: Array[CityTrait.Type] = []

		for t in _split_list(_field(row, col, "traits")):
			var key := _to_key(t)

			if CityTrait.Type.has(key):
				new_traits.append(CityTrait.Type[key])
			else:
				_warn(
					"%s (linha %d): trait '%s' (chave '%s') não existe. Válidos: %s"
					% [cname, line_no, t, key, ", ".join(CityTrait.Type.keys())]
				)

		data.traits = new_traits

		# Specializations (coluna "economy"): todos os setores com o mesmo peso
		if col.has("economy"):
			data.specializations = _build_specializations(
				_field(row, col, "economy"),
				data.specializations,
				cname,
				line_no
			)

		# Province
		var prov := _field(row, col, "province_name")

		if not prov.is_empty():
			data.province_name = prov

		# Save resource
		var err := ResourceSaver.save(data, path)

		if err != OK:
			_err(
				"%s (linha %d): erro %d (%s) ao guardar %s"
				% [cname, line_no, err, error_string(err), path]
			)
			problems += 1
		else:
			count += 1

	file.close()

	EditorInterface.get_resource_filesystem().scan()

	print("")
	print("--- Resultado do CSV")
	print("Linhas lidas (sem cabeçalho): %d" % (line_no - 1))
	print("Cidades importadas: %d" % count)
	print("Linhas ignoradas: %d" % skipped)
	print("Erros ao guardar: %d" % problems)

	if count == 0:
		_err("Nenhuma cidade foi importada. Verifica o formato do CSV acima.")

	return count


# --------------------------------------------------
# SPECIALIZATIONS
# --------------------------------------------------

# Cria uma SectorSpecialization por setor listado, todas com DEFAULT_PREVALENCE.
# Se o .tres já tinha uma specialization desse setor, reaproveita-a (mantém o peso editado à mão).
func _build_specializations(
	value: String,
	existing: Array[SectorSpecialization],
	cname: String,
	line_no: int
) -> Array[SectorSpecialization]:
	var out: Array[SectorSpecialization] = []
	var used := {}

	for raw in _split_list(value):
		var key := _to_key(raw)

		if not Economy.Sector.has(key):
			_warn(
				"%s (linha %d): setor '%s' (chave '%s') não existe em Economy.Sector. Válidos: %s"
				% [cname, line_no, raw, key, ", ".join(Economy.Sector.keys())]
			)
			continue

		var sector_value: int = Economy.Sector[key]

		if used.has(sector_value):
			_warn("%s (linha %d): setor '%s' repetido na coluna economy." % [cname, line_no, raw])
			continue
		used[sector_value] = true

		var spec: SectorSpecialization = null
		for e in existing:
			if e != null and e.sector == sector_value:
				spec = e
				break

		if spec == null:
			spec = SectorSpecialization.new()
			spec.sector = sector_value
			spec.prevalence = DEFAULT_PREVALENCE

		out.append(spec)

	return out


# --------------------------------------------------
# CSV HELPERS
# --------------------------------------------------

func _field(
	row: PackedStringArray,
	col: Dictionary,
	key: String
) -> String:
	if not col.has(key):
		return ""

	var index: int = col[key]

	if index < 0 or index >= row.size():
		return ""

	return row[index].strip_edges()


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


func _society_to_flags(value: String, cname: String, line_no: int) -> int:
	var flags := 0

	for t in _split_list(value):
		var idx := SOCIETY_FLAGS.find(t)

		if idx == -1:
			_warn(
				"%s (linha %d): society '%s' não existe nos flags. Válidos: %s"
				% [cname, line_no, t, ", ".join(SOCIETY_FLAGS)]
			)
		else:
			flags |= (1 << idx)

	return flags


# --------------------------------------------------
# UPDATE MAP POSITIONS
# --------------------------------------------------

func _update_positions() -> void:
	print("")
	print("--- A atualizar posições do mapa")

	var root := EditorInterface.get_edited_scene_root()

	if root == null:
		_warn(
			"Sem cena aberta: salto a atualização de posições. "
			+ "Abre a cena do mapa e corre outra vez."
		)
		return

	print("Cena aberta: '%s'" % root.name)

	var provinces := root.find_child("Provinces", true, false)

	if provinces == null:
		_err(
			"Não encontrei o nó 'Provinces' na cena '%s'. "
			% root.name
			+ "Confirma que a cena aberta é a do mapa."
		)
		return

	var inv := Transform3D.IDENTITY
	var portugal := provinces.get_parent() as Node3D

	if portugal != null:
		inv = portugal.global_transform.affine_inverse()
		print("Raiz do mapa: '%s'" % portugal.name)
	else:
		_warn(
			"O pai de 'Provinces' não é um Node3D. "
			+ "As posições vão ser guardadas em coordenadas globais."
		)

	var updated := 0
	var problems := 0
	var cities_found := 0
	var other_nodes := 0
	var missing: Array[String] = []
	var scene_paths := {}

	for province in provinces.get_children():
		var in_province := 0

		for city in province.get_children():

			if not city is City:
				other_nodes += 1
				print(
					"[INFO] '%s/%s' ignorado: não é do tipo City (é %s)."
					% [province.name, city.name, city.get_class()]
				)
				continue

			cities_found += 1
			in_province += 1

			var marker := _find_marker(city)

			if marker == null:
				_warn(
					"'%s' (província %s): sem Marker3D filho."
					% [city.name, province.name]
				)
				problems += 1
				continue

			var path := CityUtils.city_path(String(city.name))
			scene_paths[path] = String(city.name)

			if not ResourceLoader.exists(path):
				_warn(
					"Sem .tres para '%s' (procurado: %s). O nome do nó tem de coincidir com o 'city_name' do CSV."
					% [city.name, path]
				)
				missing.append(String(city.name))
				problems += 1
				continue

			var data := ResourceLoader.load(
				path,
				"",
				ResourceLoader.CACHE_MODE_IGNORE
			) as CityData

			if data == null:
				_warn(
					"'%s': o ficheiro %s não é um CityData válido."
					% [city.name, path]
				)
				problems += 1
				continue

			data.map_position = inv * marker.global_position
			data.province_name = String(province.name)

			var err := ResourceSaver.save(data, path)

			if err != OK:
				_err(
					"'%s': erro %d (%s) ao guardar %s"
					% [city.name, err, error_string(err), path]
				)
				problems += 1
			else:
				updated += 1

		if in_province == 0:
			print("[INFO] Província '%s' não tem nenhuma City." % province.name)

	EditorInterface.get_resource_filesystem().scan()

	# Cidades do CSV que não existem na cena
	var csv_only: Array[String] = []
	for p in _csv_paths:
		if not scene_paths.has(p):
			csv_only.append(String(_csv_paths[p]))

	print("")
	print("--- Resultado das posições")
	print("Nós City encontrados na cena: %d" % cities_found)
	print("Nós ignorados (não são City): %d" % other_nodes)
	print("Posições atualizadas: %d" % updated)
	print("Problemas: %d" % problems)

	if cities_found == 0:
		_err(
			"Nenhum nó do tipo City encontrado dentro das províncias. "
			+ "A estrutura esperada é Provinces/<Província>/<City>."
		)

	if not missing.is_empty():
		print("Cidades da cena sem .tres (não estão no CSV ou o nome é diferente):")
		for city_name in missing:
			print("   - ", city_name)

	if not csv_only.is_empty():
		print("Cidades do CSV que NÃO têm nó na cena (%d):" % csv_only.size())
		for city_name in csv_only:
			print("   - ", city_name)
		_warn("%d cidades do CSV não aparecem na cena do mapa." % csv_only.size())


# --------------------------------------------------
# MARKER HELPERS
# --------------------------------------------------

func _find_marker(city: Node) -> Marker3D:
	for c in city.get_children():
		if c is Marker3D:
			return c

	return null
