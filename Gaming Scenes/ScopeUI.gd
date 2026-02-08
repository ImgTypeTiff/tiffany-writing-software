extends Control

@export var marker_size := 12.0
@export var max_ring_distance := 200.0  # max separation of rings from center

@onready var marker_container = $MarkerContainer
@onready var inner_ring = $TextureRect
@onready var outer_ring = $TextureRect2

var markers := []
var distances_from_center := []

func set_markers(positions: Array) -> void:
	# Make sure we have enough marker nodes
	while markers.size() < positions.size():
		var marker = ColorRect.new()
		marker.color = Color(0.8,1,0.2)
		marker.size = Vector2(marker_size, marker_size)
		marker.pivot_offset = marker.size / 2
		marker_container.add_child(marker)
		markers.append(marker)
		print(marker.position)
