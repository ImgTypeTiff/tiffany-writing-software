extends Node3D

@export var _staticbody3d: StaticBody3D
@export var white_hole: Node3D
@export var exit_offset := 2.0
@export var cooldown := 0.5

var _recent := {}

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body == self or body == white_hole:
		return

	if body == _staticbody3d:
		return

	if white_hole == null:
		return

	if _recent.has(body):
		return
	print(body.name)
	_recent[body] = true
	_teleport(body)

	await get_tree().create_timer(cooldown).timeout
	_recent.erase(body)

func _teleport(body):
	var exit_dir = -white_hole.global_transform.basis.z
	body.global_position = white_hole.global_position + exit_dir * exit_offset

	if body is RigidBody3D:
		var speed = body.linear_velocity.length()
		body.linear_velocity = exit_dir * speed
