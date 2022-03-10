tool
extends EditorPlugin

const MainPanel = preload("main_screen/MainScreen.tscn")
var main_panel_instance
var tab_container

var current_main_screen_is_database

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	main_panel_instance.load_data()
	make_visible(false)
	
	tab_container = main_panel_instance.get_node("VBoxContainer/HSplitContainer/TabContainer")
			
	connect("main_screen_changed", self, "_main_screen_changed")
	
	# CONNECT NODES THAT CHANGES FILESYSTEM
	main_panel_instance.get_node("NewCategory").connect("confirmed", self, "_on_filesystem_changed")
	get_editor_interface().get_resource_filesystem().connect("filesystem_changed", main_panel_instance, "_on_filesystem_changed")

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()

func _input(event):
	if current_main_screen_is_database and event is InputEventKey and event.is_pressed() and event.get_scancode() == KEY_S and event.get_alt():
		if event.get_control():
			tab_container.get_child(tab_container.get_current_tab()).save_resource()
		elif event.get_shift():
			for c in tab_container.get_children():
				c.save_resource()

func _main_screen_changed(screen_name):
	current_main_screen_is_database = screen_name == get_plugin_name()

func _on_filesystem_changed():
	get_editor_interface().get_resource_filesystem().scan()

func has_main_screen():
	return true
	
func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
	
func get_plugin_name():
	return "Database"
	
func get_plugin_icon():
	return preload("icon.svg")
