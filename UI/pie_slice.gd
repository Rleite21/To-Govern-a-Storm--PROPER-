@tool
class_name PieSlice
extends Resource

@export var label: String = "Slice":
	set(v):
		label = v
		emit_changed()

@export var key: int = -1:
	set(v):
		key = v
		emit_changed()

@export var value: float = 1.0:
	set(v):
		value = maxf(v, 0.0)
		emit_changed()

@export var color: Color = Color(0, 0, 0, 0):
	set(v):
		color = v
		emit_changed()

@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()

@export var material: Material:
	set(v):
		material = v
		emit_changed()

@export_range(0.0, 0.5, 0.01) var explode: float = 0.0:
	set(v):
		explode = v
		emit_changed()

@export_group("On Click")
@export var spawn_scene: PackedScene:
	set(v):
		spawn_scene = v
		emit_changed()
