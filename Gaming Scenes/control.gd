extends Control # or any other Node

@onready var target_3d_node: Node3D = $"../../StaticBody3D2" # Path to your Node3D
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if camera and target_3d_node and is_in_group("signal_objects"):
		var screen_position: Vector2 = camera.unproject_position(target_3d_node.global_position)
		
		$"../../Panel".position = screen_position
