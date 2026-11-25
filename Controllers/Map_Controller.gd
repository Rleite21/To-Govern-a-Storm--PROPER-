extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var city_tab: CityTab
@export var province_tab: ProvinceTab

var selected_province: Province
var selected_city: City


func _ready() -> void:
	province_tab.closed.connect(_on_province_tab_closed)
	province_tab.city_selected.connect(_select_city)


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
	province_tab.visible = false
	city_tab.visible = false
	print("Selection cleared")


func _select_province(province: Province) -> void:
	if selected_province == province and selected_city == null and province_tab.visible:
		return
	selected_city = null  # só um pode estar selecionado
	selected_province = province
	print("Selected: ", province.name)

	city_tab.visible = false
	province_tab.show_province(province)


func _select_city(city: City) -> void:
	if selected_city == city and selected_province == null and city_tab.visible:
		return
	selected_province = null  # só um pode estar selecionado
	selected_city = city
	print("City selected: ", city.city_name)

	province_tab.visible = false
	if city.data != null:
		city_tab.show_city(city.data)
	else:
		push_warning("'%s': sem CityData" % city.name)


func _on_province_tab_closed() -> void:
	selected_province = null
