extends CharacterBody3D

@onready var _gravity
@onready var _wish_dir = Vector3.ZERO

func _apply_gravity(delta: float):
	_gravity = GravityManager.get_gravity(self)
	if _gravity == Vector3.ZERO:
		return

	up_direction = -_gravity.normalized()
	# Ensure _wish_dir is orthogonal to up_dir
	_wish_dir = (_wish_dir - up_direction * _wish_dir.dot(up_direction)).normalized()

	var curr_quat = global_basis.get_rotation_quaternion()
	var rotation_diff = Quaternion(global_basis.y, up_direction)
	var target_quat = (rotation_diff * curr_quat).normalized()

	global_basis = Basis(curr_quat.slerp(target_quat, delta * 10)).orthonormalized()

	if !is_on_floor():
		velocity += _gravity * delta

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	move_and_slide()
