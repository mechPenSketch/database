tool
extends OptionButton

var editor_plugin

var drag_data

func _draw():
	if drag_data:
		if drag_data["type"] == "files_and_dirs":
			#print(drag_data)
			var rect2_pos = get_parent().get_parent().get_position()
			var rect2 = Rect2(rect2_pos, get_size())
			var hover_border = editor_plugin.get_editor_interface().get_editor_settings().get_setting("interface/theme/accent_color")
			draw_rect(rect2, hover_border, false)

func _editor_plugin_is_set():
	editor_plugin = get_parent().editor_plugin

func drop_data(_p, data):
	print(data)

func set_dragdata(data):
	drag_data = data
	update()
