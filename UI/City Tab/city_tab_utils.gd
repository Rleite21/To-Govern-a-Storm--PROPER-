class_name CityTabUtils
extends RefCounted


static func enum_text(enum_dict: Dictionary, value: int) -> String:
	var key = enum_dict.find_key(value)

	if key == null:
		return "?"

	return String(key).replace("_", " ").capitalize()


static func format_number(number: int) -> String:
	var text := str(number)
	var result := ""
	var count := 0

	for i in range(text.length() - 1, -1, -1):
		result = text[i] + result
		count += 1

		if count % 3 == 0 and i > 0:
			result = " " + result

	return result
