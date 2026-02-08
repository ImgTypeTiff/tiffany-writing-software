class_name thegravityfpsofalltime
extends CharacterBody3D

@export var Move_Speed : float = 1.5
@export var Sprint_Speed : float = 10.0
@export var Mouse_Sens : float = 0.09
@export var Mouse_Smooth : float = 50.0
@export var JUMP_VELOCITY : float = 4.5

@export var InputDictionary : Dictionary = {
	"Forward": "ui_up",
	"Backward": "ui_down",
	"Left": "ui_left",
	"Right": "ui_right",
	"Jump": "ui_accept",
	"Escape": "ui_cancel",
	"Sprint": "ui_shift"
}

@onready var head : Node3D = %Head
@onready var camera : Camera3D = %Head/Camera3D

var _wish_dir : Vector3 = Vector3.ZERO
var _speed : float = Move_Speed
var _isMouseCaptured : bool = true

var Camera_Inp : Vector2 = Vector2()
var Rot_Vel : Vector2 = Vector2()

var smoothed_gravity_dir: Vector3 = Vector3.DOWN

# --- TILT VARIABLES ---
@onready var ltilt : Marker3D = %ilt/LTilt
@onready var rtilt : Marker3D = %ilt/RTilt
@export var TiltThreshhold : float = 0.2


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ltilt.rotation.z = TiltThreshhold
	rtilt.rotation.z = -TiltThreshhold


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Camera_Inp = event.relative


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(InputDictionary["Escape"]):
		_isMouseCaptured = !_isMouseCaptured
		if _isMouseCaptured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Camera smoothing
	Rot_Vel = Rot_Vel.lerp(Camera_Inp * Mouse_Sens, delta * Mouse_Smooth)
	head.rotate_x(deg_to_rad(Rot_Vel.y))
	head.rotate_y(-deg_to_rad(Rot_Vel.x))
	head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
	Camera_Inp = Vector2.ZERO

	camera_tilt(delta)


func _physics_process(delta: float) -> void:
	# Gravity
	var gravity = GravityManager.get_gravity(self)
	if gravity != Vector3.ZERO:
		velocity += gravity * delta

	# Align to gravity
	var gravity_dir = gravity.normalized()
	var smoothing = 6.0
	smoothed_gravity_dir = smoothed_gravity_dir.slerp(gravity_dir, delta * smoothing)
	align_to_gravity(delta, gravity_dir)

	# Jump
	if Input.is_action_just_pressed(InputDictionary["Jump"]) and is_on_floor():
		velocity += -gravity_dir * JUMP_VELOCITY

	# Input
	var input_dir : Vector2 = Input.get_vector(
		InputDictionary["Left"],
		InputDictionary["Right"],
		InputDictionary["Forward"],
		InputDictionary["Backward"]
	)

	# Wish Direction
	_wish_dir = _get_wish_direction(input_dir)

	# Movement speed
	Sprint()

	# Apply movement
	if _wish_dir != Vector3.ZERO:
		velocity = velocity.lerp(_wish_dir * _speed, delta * 10.0)
	else:
		velocity.x = move_toward(velocity.x, 0, _speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, _speed * delta * 10)

	move_and_slide()


func _get_wish_direction(input_dir: Vector2) -> Vector3:
	var forward_dir = head.global_transform.basis.z
	var right_dir = head.global_transform.basis.x

	var raw_dir = (forward_dir * input_dir.y + right_dir * input_dir.x).normalized()

	var up_dir = -GravityManager.get_gravity(self).normalized()
	var wish_dir = (raw_dir - up_dir * raw_dir.dot(up_dir)).normalized()

	return wish_dir


func Sprint() -> void:
	if Input.is_action_pressed(InputDictionary["Sprint"]):
		_speed = lerp(_speed, Sprint_Speed, 0.1)
	else:
		_speed = lerp(_speed, Move_Speed, 0.1)


func camera_tilt(delta: float) -> void:
	if Input.is_action_pressed(InputDictionary["Left"]) and Input.is_action_pressed(InputDictionary["Right"]):
		camera.rotation.z = lerp_angle(camera.rotation.z, 0 , min(delta * 5.0,1.0))
	elif Input.is_action_pressed(InputDictionary["Left"]):
		camera.rotation.z = lerp_angle(camera.rotation.z, ltilt.rotation.z , min(delta * 5.0,1.0))
	elif Input.is_action_pressed(InputDictionary["Right"]):
		camera.rotation.z = lerp_angle(camera.rotation.z, rtilt.rotation.z , min(delta * 5.0,1.0))
	else:
		camera.rotation.z = lerp_angle(camera.rotation.z, 0 , min(delta * 5.0,1.0))


func align_to_gravity(delta: float, gravity_dir: Vector3):
	var up_dir := -gravity_dir

	var current_forward := -global_transform.basis.z
	var projected_forward := current_forward - up_dir * current_forward.dot(up_dir)
	projected_forward = projected_forward.normalized()

	var target_basis := Basis.looking_at(projected_forward, up_dir)
	global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)
