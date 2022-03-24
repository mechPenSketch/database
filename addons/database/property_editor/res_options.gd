tool
extends OptionButton

var editor_plugin

var drag_data

enum {OPT_NEW, OPT_NEWAS, OPT_LOAD, OPT_CAT, OPT_SHOWINFOLDER, OPT_SHOWINCAT}

func _draw():
	if is_compatable_with_drag():
		var rect2_pos = get_parent().get_parent().get_position()
		var rect2 = Rect2(rect2_pos, get_size())
		var hover_border = editor_plugin.get_editor_interface().get_editor_settings().get_setting("interface/theme/accent_color")
		draw_rect(rect2, hover_border, false)

func _editor_plugin_is_set():
	editor_plugin = get_parent().editor_plugin

func can_drop_data(_p, _d):
	return is_compatable_with_drag()

func change_options(dir):
	get_popup().clear()
	
	if dir == "res://":
		setup_default_options()

func drop_data(_p, data):
	#print(data)
	match data["type"]:
		"files_and_dirs":
			#print("Set category")
			#print(data["files"][0])
			get_parent().resource_container.augment_config(get_property_name(), data["files"][0])

func get_property_name():
	return get_parent().property_name

func is_compatable_with_drag():
	#print(drag_data)
	if drag_data:
		if drag_data["type"] == "files_and_dirs":
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
