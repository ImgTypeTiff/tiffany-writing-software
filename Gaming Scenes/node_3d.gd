extends Node3D

@export var detection_range: float = 100.0
@export var beep_interval: float = 0.5

@onready var camera = get_parent() # Signalscope is child of Camera3D
@onready var ui_control: Control = $CanvasLayer/Control
@onready var audio_player = $AudioStreamPlayer3D

var detected_objects := []
var beep_timer := 0.0

func _process(delta):
	detected_objects.clear()

	# Detect objects in range
	for obj in get_tree().get_nodes_in_group("signal_objects"):
		var dist = global_position.distance_to(obj.global_position)
		if dist <= detection_range:
			detected_objects.append({"obj": obj, "dist": dist})
	# Request UI redraw

	ui_control.queue_redraw()
	var positions = get_detected_screen_positions()
	ui_control.set_markers(positions)

		# Optional: print distances from center
	for dist in ui_control.distances_from_center:
			print("Distance from center:", dist)

	# Beeping logic
	beep_timer -= delta
	if beep_timer <= 0 and detected_objects.size() > 0:
		var nearest_dist = 9999.0
		for data in detected_objects:
			if data["dist"] < nearest_dist:
				nearest_dist = data["dist"]

		audio_player.pitch_scale = clamp(1.5 - nearest_dist / detection_range, 0.5, 2.0)
		audio_player.volume_db = clamp(-20 + (1.0 - nearest_dist / detection_range) * 20, -80, 0)
		audio_player.play()
		beep_timer = beep_interval

func get_detected_screen_positions() -> Array:
	var arr := []
	for data in detected_objects:
		var obj = data["obj"]
		# If object is behind camera, skip
		if camera.is_position_behind(obj.global_position):
			continue
		var screen_pos = camera.unproject_position(obj.global_position)
		arr.append(screen_pos)
	return arr
