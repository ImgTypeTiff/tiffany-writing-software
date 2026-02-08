extends RayCast3D

@export var max_range := 50.0
@export var max_angle_error_deg := 6.0

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	target_position = Vector3(0, 0, -max_range)

func _physics_process(delta):
	var aim_dir = -global_transform.basis.z
	
	var distance_factor := 1.0
	if is_colliding():
		var d = global_position.distance_to(get_collision_point())
		distance_factor = clamp(d / max_range, 0.0, 1.0)
		print("Distancs:", d)
	var max_angle = deg_to_rad(max_angle_error_deg) * distance_factor

	var noisy_dir = aim_dir.rotated(
		Vector3.UP,
		rng.randf_range(-max_angle, max_angle)
	).rotated(
		Vector3.RIGHT,
		rng.randf_range(-max_angle, max_angle)
	)

	target_position = noisy_dir * max_range
	force_raycast_update()
