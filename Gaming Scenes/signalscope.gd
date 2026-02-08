# SignalScope.gd
extends Node3D

@export var scan_range: float = 1000.0
@export var blip_scene: PackedScene # A small 2D/3D blip
@export var scan_interval: float = 0.2

var blips: Array = []

func _ready():
	# optional: start scanning automatically
	scan_signals()
	set_process(true)

func _process(delta):
	scan_signals()

func scan_signals():
	# Clear previous blips
	for blip in blips:
		blip.queue_free()
	blips.clear()

	# Find all SignalEmitter nodes
	var emitters = get_tree().get_nodes_in_group("signal_objects")
	for emitter in emitters:
		var direction = (emitter.global_transform.origin - global_transform.origin)
		var distance = direction.length()
		if distance <= scan_range:
			direction = direction.normalized()
			create_blip(direction, distance, 9.0)

func create_blip(direction: Vector3, distance: float, strength: float):
	var blip_instance = blip_scene.instantiate()
	add_child(blip_instance)

	# Position the blip relative to scope
	blip_instance.transform.origin = direction * distance * 0.01 # scale for display

	# optional: scale size or brightness based on strength
	if blip_instance.has_method("set_strength"):
		blip_instance.set_strength(strength)

	blips.append(blip_instance)
