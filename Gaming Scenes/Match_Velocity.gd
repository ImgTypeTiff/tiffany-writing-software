extends RayCast3D

@onready var Planet: Node3D
@export var Player: CharacterBody3D
var collider = self.get_collider()

func _ready() -> void:
	print(collider)

func _process(delta: float) -> void:
	if collider:
		print(collider)
