extends Node
class_name DocumentManager

signal document_loaded(text: String, path: String)

func load_document(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return

	var text := file.get_as_text()
	file.close()

	document_loaded.emit(text, path)

func save_document(path, text):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SHAT")
		return
	file.store_string(text)
	if text == "coconut":
		$"../GPUParticles2D".hi()
