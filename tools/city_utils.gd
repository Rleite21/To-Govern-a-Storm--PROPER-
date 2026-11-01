
class_name CityUtils
extends RefCounted

const CITIES_DIR := "res://Data/tres/Cities/"

const ACCENTS := {
	"Á": "A", "À": "A", "Ã": "A", "Â": "A",
	"É": "E", "Ê": "E",
	"Í": "I",
	"Ó": "O", "Õ": "O", "Ô": "O",
	"Ú": "U",
	"Ç": "C"
}


static func normalize_name(value: String) -> String:
	var result := value.strip_edges().to_upper()

	for accent in ACCENTS:
		result = result.replace(accent, ACCENTS[accent])

	result = result.replace("&", " ")
	result = result.replace("-", " ")

	# Remove espaços repetidos, mas preserva os espaços entre palavras.
	var parts := result.split(" ", false)
	return " ".join(parts)


static func file_name(city_name: String) -> String:
	return normalize_name(city_name).to_lower().validate_filename() + ".tres"


static func city_path(city_name: String) -> String:
	return CITIES_DIR + file_name(city_name)


static func load_city(city_name: String) -> CityData:
	var path := city_path(city_name)

	if not ResourceLoader.exists(path):
		push_warning("CityUtils: não existe CityData para '%s' (%s)" % [city_name, path])
		return null

	var data := ResourceLoader.load(
		path,
		"",
		ResourceLoader.CACHE_MODE_IGNORE
	) as CityData

	if data == null:
		push_warning("CityUtils: não foi possível carregar '%s'" % path)

	return data
