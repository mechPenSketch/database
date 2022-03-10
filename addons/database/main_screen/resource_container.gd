tool
extends ScrollContainer

# COMPARING PROPERT INSPECTOR
# 	@@3851 is the EditorInspector

var parent_category
var file_name
var file_path

const base_dir = "res://addons/database/property_editor/"
const extension = ".tscn"

var associated_treeitem
var associated_resource
var associated_script
var has_unsaved_changes:bool setget set_unsaved_changes

func list_properties(c, fp:String, fn):
	parent_category = c
	file_path = fp
	file_name = fn
	var index = [0, 0]
	
	associated_resource = ResourceLoader.load(file_path)
	associated_script = associated_resource.get_script()
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

func get_pe_by_type(property):
	match property["type"]:
		TYPE_BOOL:
			return "Bool"
		TYPE_REAL:
			return "Float"
		TYPE_INT:
			return "Int"
		_:
			return "String"

func _on_value_changed(value, tree_index):
	var node = $VBoxContainer
	for i in tree_index:
		node = node.get_child(i)
	
	associated_resource.set(node.property_name, value)
	
	if value != node.prev_val:
		set_unsaved_changes(true)

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
