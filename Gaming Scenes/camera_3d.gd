extends Node3D

@export var max_range := 50.0
@export var rays_per_scan := 9
@export var max_angle_error_deg := 6.0

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func scan_cone_average() -> Dictionary:
	var space := get_world_3d().direct_space_state
	var origin := global_position
	var forward := -global_transform.basis.z

	var hit_count := 0
	var position_sum := Vector3.ZERO
	var distance_sum := 0.0

	for i in rays_per_scan:
		var angle := deg_to_rad(max_angle_error_deg)

		var yaw := rng.randf_range(-angle, angle)
		var pitch := rng.randf_range(-angle, angle)

		var dir := forward \
			.rotated(Vector3.UP, yaw) \
			.rotated(Vector3.RIGHT, pitch)

		# Create the query correctly
		var query = PhysicsRayQueryParameters3D.new()
		query.from = origin
		query.to = origin + dir * max_range
		query.collision_mask = 1 << 2  # set which layers to hit

		var result := space.intersect_ray(query)

		if result:
			var d := origin.distance_to(result.position)
			position_sum += result.position
			distance_sum += d
			hit_count += 1

	if hit_count == 0:
		return {}

	return {
		"position": position_sum / hit_count,
		"distance": distance_sum / hit_count,
		"confidence": float(hit_count) / float(rays_per_scan)
	}


func _physics_process(delta):
	var scan := scan_cone_average()

	if scan:
		print("Estimated distance:", scan.distance)
		print("Estimated position:", scan.position)
		print("Confidence:", scan.confidence)
