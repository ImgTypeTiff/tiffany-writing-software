extends Node2D

@export_file("*.tscn ") var file_path: String

func _ready() -> void:
	Loading.load_scene(file_path, true)
