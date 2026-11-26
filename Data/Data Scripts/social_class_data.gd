class_name SocialClassTemplate
extends Resource

@export var type: SocialClassEnums.Type
@export_range(0, 100) var base_militancy: float = 20.0
@export_range(0, 100) var base_consciousness: float = 20.0
@export var convictions: Dictionary = {}
@export var default_traits: Array[SocialClassEnums.Trait] = []
@export var militancy_noise: float = 10.0
@export var consciousness_noise: float = 10.0
@export var ownership: Array[float] = []
