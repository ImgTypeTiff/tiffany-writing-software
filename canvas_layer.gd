extends CanvasLayer

@export var indicator_scene: PackedScene
@export var player_camera: Camera3D

var indicators := {}

func _ready():
	for emitter in get_tree().get_nodes_in_group("SignalEmitter"):
		var indicator = indicator_scene.instantiate()
		add_child(indicator)
		indicator.set_target(emitter, player_camera)
		indicators[emitter] = indicator
