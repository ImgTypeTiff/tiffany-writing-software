extends TabContainer

@onready var tabs: TabContainer = self

func _ready() -> void:
	var tab_bar := tabs.get_tab_bar()
	tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS
	tab_bar.tab_close_pressed.connect(_on_tab_close_pressed)

func _on_tab_close_pressed(tab_index: int) -> void:
	var tab := tabs.get_child(tab_index)
	if tab:
		tab.queue_free()
