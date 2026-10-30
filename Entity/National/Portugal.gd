extends Node

@onready var provinces := get_node_or_null("Provinces")
@onready var cities := get_node_or_null("Cities")
var world_seed: int = 0


func _ready() -> void:
	print("Portugal initialized! Running routine checks...\n")
	print("[MAIN]- Checking provinces...")
	initialize_provinces()
	world_seed = randi()  # ou carregar do save
	for city in get_tree().get_nodes_in_group("cities"):
		(city as City).initialize(world_seed)

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
