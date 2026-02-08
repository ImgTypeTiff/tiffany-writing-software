extends RayCast3D

@export var player: CharacterBody3D
var planet: Node3D

func _process(delta: float) -> void:
	var collider = get_collider()
	if Input.is_action_just_pressed("enter"):
		if collider == planet:
			planet = null
			return
		if collider:
			if collider.is_in_group("Planet"):
				planet = collider
				print(planet)
	if planet:
		if Input.is_action_just_pressed("match_vel"):
			print(planet.AccelerationByGravity)
			player.velocity = planet.AccelerationByGravity
