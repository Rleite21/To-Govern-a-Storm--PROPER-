# portugal_map.gd
extends Node3D

@onready var camera: Camera3D = $Camera3D

var selected_province: Province

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from := camera.project_ray_origin(event.position)
		var to := from + camera.project_ray_normal(event.position) * 1000.0

		var query := PhysicsRayQueryParameters3D.create(from, to)
		var result := get_world_3d().direct_space_state.intersect_ray(query)

		_select(_find_province(result.collider) if result else null)

# Walks up from the collider until it finds a Province,
# so it works however deep the StaticBody3D is nested
func _find_province(node: Node) -> Province:
	while node != null:
		if node is Province:
			return node
		node = node.get_parent()
	return null

func _select(province: Province) -> void:
	if selected_province == province:
		return
	selected_province = province
	if province:
		print("Selected: ", province.name)
		print("-" + province.get_province_name() + " has population of ", province.get_pop())
		province.print_cities()
	else:
		print("Selection cleared")
