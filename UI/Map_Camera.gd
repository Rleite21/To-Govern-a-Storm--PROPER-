
extends Camera3D

@export var move_speed: float = 10.0
@export var turn_speed: float = 1.5
@export var mouse_sensitivity: float = 0.003

# Zoom limits
@export var zoom_speed: float = 2.0
@export var min_fov: float = 25.0
@export var max_fov: float = 90.0

# Look up/down limit
@export var max_pitch: float = 1.4

# Vertical movement limits in world space
@export var min_height: float = 1.0
@export var max_height: float = 20.0

var mouse_look: bool = false
var yaw: float = 0.0
var pitch: float = 0.0


func _ready() -> void:
	yaw = rotation.y
	pitch = rotation.x


func _input(event: InputEvent) -> void:
	# Hold middle mouse to rotate the camera.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			mouse_look = event.pressed

			Input.mouse_mode = (
				Input.MOUSE_MODE_CAPTURED
				if mouse_look
				else Input.MOUSE_MODE_VISIBLE
			)

		# Scroll up to zoom in.
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			fov = max(min_fov, fov - zoom_speed)

		# Scroll down to zoom out.
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			fov = min(max_fov, fov + zoom_speed)

	# Mouse look while holding the middle button.
	elif event is InputEventMouseMotion and mouse_look:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity

		# Limit how far up or down the camera can look.
		pitch = clamp(pitch, -max_pitch, max_pitch)


func _process(delta: float) -> void:
	# Q and E rotate horizontally.
	if Input.is_key_pressed(KEY_Q):
		yaw += turn_speed * delta

	if Input.is_key_pressed(KEY_E):
		yaw -= turn_speed * delta

	# Apply camera rotation.
	rotation = Vector3(pitch, yaw, 0.0)

	# WASD movement along fixed world X/Z axes.
	var move_direction := Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		move_direction.z -= 1.0

	if Input.is_key_pressed(KEY_S):
		move_direction.z += 1.0

	if Input.is_key_pressed(KEY_A):
		move_direction.x -= 1.0

	if Input.is_key_pressed(KEY_D):
		move_direction.x += 1.0

	# Space moves up; Ctrl moves down.
	if Input.is_key_pressed(KEY_SPACE):
		move_direction.y += 1.0

	if Input.is_key_pressed(KEY_CTRL):
		move_direction.y -= 1.0

	# Normalize to prevent faster diagonal movement.
	if move_direction.length_squared() > 0.0:
		move_direction = move_direction.normalized()

		# Move along the world's axes.
		global_position += move_direction * move_speed * delta

	# Clamp vertical position to the allowed height range.
	global_position.y = clamp(
		global_position.y,
		min_height,
		max_height
	)
