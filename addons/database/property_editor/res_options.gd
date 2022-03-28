tool
extends OptionButton

var editor_plugin

var drag_data
var class_hint

var category_folder
enum {OPT_NEW, OPT_NEWAS, OPT_LOAD, OPT_INSTALOAD, OPT_CAT, OPT_SHOWINFOLDER, OPT_SHOWINCAT}

const RES_EXTS = ["res", "tres"]
signal resource_is_set

func _draw():
	if is_compatable_with_drag():
		var rect2_pos = get_parent().get_parent().get_position()
		var rect2 = Rect2(rect2_pos, get_size())
		var hover_border = editor_plugin.get_editor_interface().get_editor_settings().get_setting("interface/theme/accent_color")
		draw_rect(rect2, hover_border, false)

func _editor_plugin_is_set():
	editor_plugin = get_parent().editor_plugin

func _item_selected(index:int):
	var id = get_item_id(index)
	
	match id:
		OPT_NEW:
			print("New res")
		OPT_NEWAS:
			print("New res As...")
		OPT_LOAD:
			print("Open Filesystem")
		OPT_INSTALOAD:
			#SETTING A RESOURCE
			var file_name = get_item_text(index)
			var full_path = category_folder.plus_file(file_name)
			emit_signal("resource_is_set", get_parent(), full_path)
		OPT_CAT:
			print("Pick a Category")

func can_drop_data(_p, _d):
	return is_compatable_with_drag()

func change_options(dir):
	get_popup().clear()
	
	category_folder = dir
	
	if dir == "res://":
		setup_default_options()
	else:
		var main_dir = Directory.new()
		var err = main_dir.open(dir)
		
		match err:
			OK:
				go_through_folder_for_options(main_dir)
			_:
				print(err)

func drop_data(_p, data):
	#print(data)
	match data["type"]:
		"files_and_dirs":
			get_parent().resource_container.augment_config(get_property_name(), data["files"][0])
		"files":
			print(data["files"][0])
			set_text(data["files"][0].get_file())
			emit_signal("resource_is_set", get_parent(), data["files"][0])

func go_through_folder_for_options(dir:Directory, base_folder:String = ""):
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while file_name != "":
		
		# IF THE ITEM IS A FOLDER
		if dir.current_is_dir():
			var sub_directory = Directory.new()
			sub_directory.open(dir.get_current_dir().plus_file(file_name))
			var folder = file_name
			if base_folder:
				folder = base_folder.plus_file(file_name)
			go_through_folder_for_options(sub_directory, folder)
		
		# ELSE, IF ITEM IS A FILE
		elif file_name.get_extension() in RES_EXTS:
			var final_filename = file_name
			if base_folder:
				final_filename = base_folder.plus_file(file_name)
			get_popup().add_item(final_filename, OPT_INSTALOAD)
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

func get_property_name():
	return get_parent().property_name

func is_compatable_with_drag():
	#print(drag_data)
	if drag_data:
		match drag_data["type"]:
			"files_and_dirs":
				return true
			"files":
				return is_compatable_with_file(drag_data["files"][0])
			
	return false

func is_compatable_with_file(file):
	var extension = file.get_extension()
	
	match class_hint:
		"Texture":
			if extension in ["png", "jpeg", "svg"]:
				return true
		_:
			if extension in RES_EXTS:
				return true
		
	return false

func set_dragdata(data):
	drag_data = data
	update()

func setup_default_options():
	var popup:PopupMenu = get_popup()
	
	popup.add_item("New Resource", OPT_NEW)
	popup.add_item("New Class as...", OPT_NEWAS)
	
	popup.add_separator()
	
	popup.add_item("Load", OPT_LOAD)
	popup.add_item("Limit to Category", OPT_CAT)
	
	popup.add_separator()
	
	popup.add_item("Show in Filesystem")
	popup.add_item("Show in Datasystem")
