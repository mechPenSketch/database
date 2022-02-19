tool
extends EditorPlugin

const MainPanel = preload("main_screen/MainScreen.tscn")
var main_panel_instance
const Tab = preload("main_screen/Tab.tscn")

const DATA_DIR = "res://data"

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
	
	# LOADING CONTENT
	
	#	DEFINE NEW TAB
	var tab_container = main_panel_instance.get_node("TabContainer")
	#print (tab_container.get_current_tab_control())
	
	var dir = Directory.new()
	var open_error = dir.open(DATA_DIR)
	
	match open_error:
		OK:
			# FOR EVERY ITEM IN /content
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			while file_name != "":
				# IF THE ITEM IS A FOLDER
				if dir.current_is_dir():
					# DD NEW TAB TO CONTAINER
					var tab_instance = Tab.instance()
					tab_instance.set_name(file_name.capitalize())
					main_panel_instance.add_child(tab_instance)
				file_name = dir.get_next()
			dir.list_dir_end()
		ERR_INVALID_PARAMETER:
			# NEW FOLDER
			dir.make_dir("data")
		_:
			print(open_error)

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
