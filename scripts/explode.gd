extends Node


func explode():
	Loading.load_scene("res://new folder/explode.tscn")

func implode(position):
	var expound = preload("res://new folder/explode.tscn")
	var new_expound = expound.instantiate()
	new_expound.position = position.position
