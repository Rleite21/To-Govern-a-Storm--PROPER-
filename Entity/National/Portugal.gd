extends Node

@onready var provinces := get_node_or_null("Provinces")
@onready var cities := get_node_or_null("Cities")

func _ready() -> void:
	print("Portugal initialized! Running routine checks...\n")
	print("[MAIN]- Checking provinces...")
	initialize_provinces()

func _process(delta: float) -> void:
	pass

func initialize_provinces() -> void:
	if provinces == null:
		push_error("Provinces node not found!")
		return

	for child in provinces.get_children():
		if not child is Province:
			continue
		if not child.initialize():
			return  # stop on the first broken province, like before

	print("Provinces initialized successfully!")
