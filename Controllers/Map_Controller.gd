extends Node3D

@onready var camera: Camera3D = $Camera3D

var selected_province: Province
var selected_city: City

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from := camera.project_ray_origin(event.position)
		var to := from + camera.project_ray_normal(event.position) * 1000.0

		var query := PhysicsRayQueryParameters3D.create(from, to)
		var result := get_world_3d().direct_space_state.intersect_ray(query)

		if not result:
			_clear_selection()
			return

		# Cidade primeiro: é filha da província, por isso também levaria à província
		var city := _find_city(result.collider)
		if city != null:
			_select_city(city)
			return

		var province := _find_province(result.collider)
		if province != null:
			_select_province(province)
		else:
			_clear_selection()

# Sobe a árvore a partir do collider até encontrar um City
func _find_city(node: Node) -> City:
	while node != null:
		if node is City:
			return node
		node = node.get_parent()
	return null

# Sobe a árvore a partir do collider até encontrar uma Province
func _find_province(node: Node) -> Province:
	while node != null:
		if node is Province:
			return node
		node = node.get_parent()
	return null

func _clear_selection() -> void:
	if selected_city == null and selected_province == null:
		return
	selected_city = null
	selected_province = null
	print("Selection cleared")

func _select_province(province: Province) -> void:
	if selected_province == province and selected_city == null:
		return
	selected_city = null  # só um pode estar selecionado
	selected_province = province
	print("Selected: ", province.name)
	print("-" + province.get_province_name() + " has population of ", province.get_pop())
	province.print_cities()

func _select_city(city: City) -> void:
	if selected_city == city and selected_province == null:
		return
	selected_province = null  # só um pode estar selecionado
	selected_city = city
	print("City selected: ", city.city_name, " ", )
