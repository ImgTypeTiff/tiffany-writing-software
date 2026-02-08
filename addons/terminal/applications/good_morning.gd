extends TerminalApplication

func _init() -> void:
	name = "good morning"
	description = "you should start here."

func run(terminal : Terminal, params : Array):
	terminal.add_to_log(
		"Good Morning.
		
		Welcome to the TIFF PROJECT INSTALLATION HUB
		
		Run \"tiff playable_scene_list\".
		
		Good luck."
	)
