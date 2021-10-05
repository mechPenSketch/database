tool
extends EditorPlugin

const MainPanel = preload("main_screen/MainScreen.tscn")
var main_panel_instance
const Tab = preload("main_screen/Tab.tscn")

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
	
	# LOADING CONTENT
	
	#	DEFINE NEW TAB
	var tab_container = main_panel_instance.get_node("TabContainer")
	
	
	var dir = Directory.new()
	match dir.open("data"):
		OK:
			# FOR EVERY ITEM IN /content
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				# IF THE ITEM IS A FOLDER
				if dir.current_is_dir():
					# DD NEW TAB TO CONTAINER
					var tab_instance = Tab.instance()
					tab_instance.set_name(file_name.capitalize())
					main_panel_instance.add_child(tab_instance)
				file_name.go_next()
		ERR_FILE_NOT_FOUND:
			# NEW FOLDER
			dir.make_dir("data")
		_:
			print("Error")

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()

func has_main_screen():
	return true
	
func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
	
func get_plugin_name():
	return "Database"
	
func get_plugin_icon():
	return preload("icon.svg")
