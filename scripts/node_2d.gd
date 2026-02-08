extends Control

@onready var tabs: TabContainer = $TabContainer
@onready var file_dialog: FileDialog = $FileDialog
@onready var document_manager: DocumentManager = $DocumentManager
@onready var file_menu: PopupMenu = $MenuBar/"File Menu"

@export  var DocumentTabScene: PackedScene

# ----------------------------
# Startup
# ----------------------------
func _ready() -> void:
#	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
#	file_dialog.filters = [
#		"*.txt ; Text Files",
#		"*.md ; Markdown Files"
#	]
	
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	document_manager.document_loaded.connect(_on_document_loaded)
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	file_dialog.current_dir = path
	print(path)
#	
	_setup_file_menu()
	new_tab()

# ----------------------------
# Tabs
# ----------------------------
func new_tab(text := "", path := "") -> void:
	var tab := DocumentTabScene.instantiate() as DocumentTab
	tab.file_path = path
	tab.set_text(text)

	tab.dirty_changed.connect(func(_dirty):
		update_tab_title(tab)
	)

	tabs.add_child(tab)
	tabs.current_tab = tabs.get_tab_count() - 1
	update_tab_title(tab)

func get_current_tab() -> DocumentTab:
	if tabs.get_tab_count() == 0:
		return null
	return tabs.get_child(tabs.current_tab) as DocumentTab

func update_tab_title(tab: DocumentTab) -> void:
	var idx := tab.get_index()
	var title := "Untitled"

	if tab.file_path != "":
		title = tab.file_path.get_file()

	if tab.dirty:
		title += " •"

	tabs.set_tab_title(idx, title)

# ----------------------------
# File Loading
# ----------------------------
func _on_file_dialog_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		document_manager.load_document(path)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_save_to_path(path)

func _on_document_loaded(text: String, path: String) -> void:
	new_tab(text, path)

# ----------------------------
# Saving
# ----------------------------
func save_current_tab(force_dialog := false) -> void:
	var tab := get_current_tab()
	if tab == null:
		return

	if tab.file_path == "" or force_dialog:
		print(tab.file_path)
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.popup_centered()
	else:
		_save_to_path(tab.file_path)

func _save_to_path(path: String) -> void:
	var tab := get_current_tab()
	if tab == null:
		return

	tab.file_path = path
	document_manager.save_document(path, tab.get_text())
	tab.dirty = false
	update_tab_title(tab)

# ----------------------------
# PopupMenu Setup
# ----------------------------
func _setup_file_menu() -> void:
	file_menu.clear()

	# Add items
	file_menu.add_item("New", 0)
	file_menu.add_item("Open…", 1)
	file_menu.add_item("Save", 2)
	file_menu.add_item("Save As…", 3)
	file_menu.add_item("explode", 4)
	file_menu.add_item("TERMINAL", 5)
	# Add submenus (PopupMenu supports them)
	file_menu.add_submenu_item("File", "file_submenu")

	# Create submenu
	var sub = PopupMenu.new()
	sub.name = "file_submenu"
	add_child(sub)

	sub.add_item("New", 0)
	sub.add_item("Open…", 1)
	sub.add_item("Save", 2)
	sub.add_item("Save As…", 3)
	sub.add_item("Explode", 4)
	

	sub.connect("id_pressed", Callable(self, "_on_file_menu_id_pressed"))

	# Connect main menu
	file_menu.connect("id_pressed", Callable(self, "_on_file_menu_id_pressed"))

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0:
			new_tab()
		1:
			_menu_open()
		2:
			save_current_tab()
		3:
			save_current_tab(true)
		4:
			get_tree().quit()
		5:
			Loading.load_scene("res://addons/terminal/terminal_menu.tscn")

func _menu_open() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup()
