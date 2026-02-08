extends Control
class_name DocumentTab

@onready var editor: TextEdit = %TextEdit

var file_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var dirty := false

signal dirty_changed(dirty: bool)

func set_text(text: String) -> void:
	%TextEdit.text = text
	dirty = false
	emit_signal("dirty_changed", dirty)

func get_text() -> String:
	return editor.text

func mark_dirty() -> void:
	if not dirty:
		dirty = true
		emit_signal("dirty_changed", dirty)

func _ready() -> void:
	editor.text_changed.connect(mark_dirty)
