extends Control

@export var max_offset: float = 200.0
@export var snap_threshold: float = 2.0
@export var separation_lerp_speed: float = 10.0

var target: Node3D
var camera: Camera3D

var current_separation: float = 0.0

func _ready():
	await get_tree().process_frame

	$LeftHalf.pivot_offset = Vector2($LeftHalf.size.x, $LeftHalf.size.y * 0.5)
	$RightHalf.pivot_offset = Vector2(0, $RightHalf.size.y * 0.5)


func set_target(p_target: Node3D, p_camera: Camera3D):
	target = p_target
	camera = p_camera

func _process(delta):
	if not target or not camera:
		return

	var to_target = (target.global_position - camera.global_position).normalized()
	var forward = -camera.global_transform.basis.z.normalized()

	var angle = forward.angle_to(to_target)

	var target_separation = clamp(angle / deg_to_rad(45.0), 0.0, 1.0) * max_offset

	var center := size * 0.5
	var half_width = $LeftHalf.size.x * 0.5
	var min_separation = half_width

	target_separation = max(target_separation, min_separation)

	current_separation = lerp(
		current_separation,
		target_separation,
		separation_lerp_speed * delta
	)

	if abs(current_separation - min_separation) <= snap_threshold:
		current_separation = min_separation

	$LeftHalf.position = Vector2(center.x - current_separation, center.y)
	$RightHalf.position = Vector2(center.x + current_separation, center.y)
	
