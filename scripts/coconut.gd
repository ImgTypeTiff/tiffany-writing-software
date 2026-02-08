extends Node2D

func _ready() -> void:
	if uid_to_path("uid://doe45tcpehl1b"):
		Loading.load_scene("res://WritingCore.tscn", true)

static func uid_to_path(uid_string: String) -> String:
	var uid_value = ResourceUID.text_to_id(uid_string)
	if ResourceUID.has_id(uid_value):
		return ResourceUID.get_id_path(uid_value)
	else:
		print("Error: Invalid UID or UID not found")
	return ""
