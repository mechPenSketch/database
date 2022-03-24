tool
extends ScrollContainer

# COMPARING PROPERT INSPECTOR
# 	@@3851 is the EditorInspector

var file_name
var file_path
var category_folder

const base_dir = "res://addons/database/property_editor/"
const extension = ".tscn"

var main_screen
var editor_plugin

var current_dragdata

var associated_treeitem
var associated_resource
var associated_script
var has_unsaved_changes:bool setget set_unsaved_changes

enum {OPT_NEW, OPT_NEWAS, OPT_LOAD, OPT_CAT, OPT_SHOWINFOLDER, OPT_SHOWINCAT}

func _gui_input(event):
	if event is InputEventMouseMotion:
		if event.get_pressure() == 0 and current_dragdata:
			set_dragdata_onto_props($VBoxContainer, null)
			current_dragdata = null

func augment_config(property_name, target_folder):
	#print(category_folder)
	var config = main_screen.cat_config[category_folder]
	
	config.set_value("Properties", property_name, target_folder)
	
	var config_path = category_folder.plus_file("config.cfg")
	config.save(config_path)
	editor_plugin._on_changing_filesystem()

func can_drop_data(_p, data):
	set_dragdata_onto_props($VBoxContainer, data)
	current_dragdata = data
	return false

func set_dragdata_onto_props(node, data):
	if node is DataPropertyEditor:
		if node.has_node("OptionButton"):
			node.get_node("OptionButton").set_dragdata(data)
	else:
		for c in node.get_children():
			set_dragdata_onto_props(c, data)

func list_properties(c, cf:String, fn):
	main_screen = c
	file_path = cf.plus_file(fn)
	file_name = fn
	category_folder = cf
	var index = [0, 0]
	
	associated_resource = ResourceLoader.load(file_path)
	associated_script = associated_resource.get_script()
	#print(associated_script.get_script_property_list())
	for pl in associated_script.get_script_property_list():
		# THE PROPERTY SHOULD BE ABLE TO BE STORED
		if pl["usage"] % 2 == PROPERTY_USAGE_STORAGE:
			var pe_type = get_pe_by_type(pl)
			# PROPERTY EDITOR
			var pe = load(base_dir + pe_type + extension)
			var pe_inst = pe.instance()
			pe_inst.set_property(pl)
			pe_inst.file_name = pe_type
			pe_inst.tree_index = index.duplicate()
			$VBoxContainer/GridContainer.add_child(pe_inst)
			index[1] += 1
			pe_inst.resource_container = self
			pe_inst.set_editor_plugin(editor_plugin)
			
			# VALUE
			var value = associated_resource.get(pl["name"])
			pe_inst.prev_val = value
			match pe_type:
				"Bool":
					var check_box = pe_inst.get_node("CheckBox")
					check_box.connect("toggled", self, "_on_value_changed", [pe_inst.tree_index])
					
					if value:
						check_box.set_pressed(value)
				"Float", "Int":
					var spinbox = pe_inst.get_node("SpinBox")
					spinbox.connect("value_changed", self, "_on_value_changed", [pe_inst.tree_index])
					
					if value:
						spinbox.set_value(float(value))
				"String":
					var line_edit = pe_inst.get_node("LineEdit")
					line_edit.connect("text_changed", self, "_on_value_changed", [pe_inst.tree_index])
					
					if value:
						line_edit.set_text(value)
				"Resource":
					var option_btn = pe_inst.get_node("OptionButton")
					setup_resource_options(option_btn)
					
					if value:
						option_btn.set_text(value.get_name())
					else:
						option_btn.set_text("[empty]")

func get_pe_by_type(property):
	match property["type"]:
		TYPE_BOOL:
			return "Bool"
		TYPE_REAL:
			return "Float"
		TYPE_INT:
			return "Int"
		TYPE_OBJECT:
			return "Resource"
		_:
			return "String"

func _on_value_changed(value, tree_index):
	var node = $VBoxContainer
	for i in tree_index:
		node = node.get_child(i)
	
	associated_resource.set(node.property_name, value)
	
	if value != node.prev_val:
		set_unsaved_changes(true)

func _on_option_pressed(index:int, tree_index):
	var node = $VBoxContainer
	for i in tree_index:
		node = node.get_child(i)
	
	var id = node.get_item_id(index)
	
	match id:
		OPT_NEW:
			print("New res")
		OPT_NEWAS:
			print("New res As...")
		OPT_LOAD:
			print("Open Filesystem")
		OPT_CAT:
			print("Pick a Category")

func save_resource():
	if associated_treeitem:
		ResourceSaver.save(file_path, associated_resource)
		save_property_aftermath($VBoxContainer)
		set_unsaved_changes(false)

func save_property_aftermath(node):
	if node is VBoxContainer or node is GridContainer:
		for child in node.get_children():
			save_property_aftermath(child)
	else:
		node.prev_val = associated_resource.get(node.property_name)

func set_unsaved_changes(value:bool):
	has_unsaved_changes = value
	var new_text = file_name
	
	if value:
		new_text += "(*)"
	
	associated_treeitem.set_text(0, new_text)

func setup_resource_options(option_btn:OptionButton):
	var popup:PopupMenu = option_btn.get_popup()
	
	popup.add_item("New Resource", OPT_NEW)
	popup.add_item("New Class as...", OPT_NEWAS)
	
	popup.add_separator()
	
	popup.add_item("Load", OPT_LOAD)
	popup.add_item("Limit to Category", OPT_CAT)
	
	popup.add_separator()
	
	popup.add_item("Show in Filesystem")
	popup.add_item("Show in Datasystem")

func set_editor_plugin(node):
	editor_plugin = node
