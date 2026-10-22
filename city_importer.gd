@tool
extends EditorScript

const CSV_PATH := "res://Data/csv files/Cities.csv"
const OUTPUT_DIR := "res://Data/tres/Cities/"
const SPECIALIZATION_PREVALENCE := 2.0  # Mesmo valor para todas as especializações

const SECTOR_MAP := {
	"agriculture": Economy.Sector.AGRICULTURE,
	"heavy industry": Economy.Sector.HEAVY_INDUSTRY,
	"finance": Economy.Sector.FINANCE,
	"transportation": Economy.Sector.TRANSPORTATION,
	"mining & raw materials": Economy.Sector.MINING,
	"trade & services": Economy.Sector.TRADE_SERVICES,
	"arms industry": Economy.Sector.ARMS,
	"manufacturing": Economy.Sector.MANUFACTURING,
	"fishing": Economy.Sector.FISHING,
	"portuary": Economy.Sector.PORTUARY,
	"civil engineering": Economy.Sector.CIVIL_ENGINEERING,
}

func _run() -> void:
	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("Não consegui abrir %s (erro %d)" % [CSV_PATH, FileAccess.get_open_error()])
		return

	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	# Cabeçalho -> índice de cada coluna
	var header := file.get_csv_line(",")
	var col := {}
	for i in header.size():
		col[header[i].strip_edges().trim_prefix("\uFEFF")] = i
	for required in ["city_name", "description", "population", "economy", "society", "density", "traits"]:
		if not col.has(required):
			push_error("Falta a coluna '%s' no CSV" % required)
			return

	var created := 0
	var warnings := 0
	while not file.eof_reached():
		var row := file.get_csv_line(",")
		if row.size() <= col["city_name"] or row[col["city_name"]].strip_edges().is_empty():
			continue

		var data := CityData.new()
		data.city_name = row[col["city_name"]].strip_edges()
		data.description = row[col["description"]].strip_edges()
		data.population = row[col["population"]].strip_edges().to_int()

		# Density
		var density_value := CityDensity.from_string(row[col["density"]])
		if density_value == -1:
			push_warning("%s: density desconhecida '%s'" % [data.city_name, row[col["density"]]])
			warnings += 1
		else:
			data.density = density_value as CityDensity.Level

		# Cultural stance (flags)
		data.society = CulturalStance.parse_flags(row[col["society"]])

		# Traços
		for t in row[col["traits"]].split(","):
			if t.strip_edges().is_empty():
				continue
			var value := CityTrait.from_string(t)
			if value == -1:
				push_warning("%s: traço desconhecido '%s'" % [data.city_name, t.strip_edges()])
				warnings += 1
			else:
				data.traits.append(value as CityTrait.Type)

		# Especializações (todas com o mesmo prevalence)
		for s in row[col["economy"]].split(","):
			var key := s.strip_edges().to_lower()
			if key.is_empty():
				continue
			if SECTOR_MAP.has(key):
				var spec := SectorSpecialization.new()
				spec.sector = SECTOR_MAP[key]
				spec.prevalence = SPECIALIZATION_PREVALENCE
				data.specializations.append(spec)
			else:
				push_warning("%s: setor desconhecido '%s'" % [data.city_name, key])
				warnings += 1

		var path := OUTPUT_DIR + data.city_name.validate_filename() + ".tres"
		var err := ResourceSaver.save(data, path)
		if err != OK:
			push_error("Erro %d ao guardar %s" % [err, path])
			warnings += 1
		else:
			created += 1

	EditorInterface.get_resource_filesystem().scan()
	print("Importação concluída: %d cidades criadas, %d avisos." % [created, warnings])
