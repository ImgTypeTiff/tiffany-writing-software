extends TerminalApplication

const file_path = ""
var possible_scene: String
var scene_to_load: String

var command_params = [
	"-l", "-s", "-p", "-r", "-h"
]

func _init() -> void:
	name = "tiff"
	description = "your favorite scene loader command"

func run(terminal : Terminal, params : Array):

	var run: Array = paramidentify(params, terminal)
	for param in run:
		print(param)
		var files = DirAccess.get_files_at("res://tiff scenes/")
		var path = "res://tiff scenes/"
		if param == "-l":
			for file in files:
				if(".uid" in file):
					pass
				elif (".tscn" in file):
					var file_name : String = file.replace('.remap', '') #Godot 4 production, renames files when compiled, automapped in load function
					terminal.add_to_log(file_name)
		if param == "-r":
			scene_to_load = path+possible_scene
			if FileAccess.file_exists(scene_to_load):
				Loading.load_scene(scene_to_load)
			else:
				terminal.add_error("not valid scene file. Did you add the file extension?")
		if param == "-h":
			terminal.add_to_log(
"-l: lists all loadable scenes. Usage: \" tiff -l \"
-r: Runs a inputed scene. Usage: \" tiff -r <scene_file> \"
-h: Shows help message. Usage: \" tiff -h \"")
	if !params:
		terminal.add_to_log("
-l: lists all loadable scenes. Usage: \" tiff -l \"
-r: Runs a inputed scene. Usage: \" tiff -r <scene_file> \"
-h: Shows help message. Usage: \" tiff -h \"")
func paramidentify(params: Array, terminal: Terminal):
	var run: Array = []
	var last_param: String
	for param in params:
		if param in command_params:
			run.push_back(param)
			last_param = param
		else:
				if last_param == "-r":
					possible_scene = param
	return run
