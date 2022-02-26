tool
extends ScrollContainer

# COMPARING PROPERT INSPECTOR
# 	@@3851 is the EditorInspector

var parent_category
var file_name
var file_path

const base_dir = "res://addons/database/property_editor/"
const extension = ".tscn"

var associated_resource
var associated_script
var has_unsaved_changes:bool setget set_unsaved_changes

func list_properties(c, fp:String, fn):
	parent_category = c
	file_path = fp
	file_name = fn
	
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
			$VBoxContainer.add_child(pe_inst)
			
			# VALUE
			var value = associated_resource.get(pl["name"])
			match pe_type:
				"String":
					var line_edit = pe_inst.get_node("LineEdit")
					line_edit.connect("text_changed", self, "_on_value_changed", [pe_inst.get_index()])
					
					if value:
						line_edit.set_text(value)

func get_pe_by_type(property):
	match property["type"]:
		_:
			return "String"

func _on_value_changed(value, child_index):
	var property_name = $VBoxContainer.get_child(child_index).property_name
	if value != associated_resource.get(property_name):
		set_unsaved_changes(true)

func save_resource():
	save_property($VBoxContainer)
	ResourceSaver.save(file_path, associated_resource)
	set_unsaved_changes(false)

func save_property(node):
	if node is VBoxContainer or node is ItemList:
		for child in node.get_children():
			save_property(child)
	else:
		var value
		match node.file_name:
			"String":
				value = node.get_node("LineEdit").get_text()
		associated_resource.set(node.property_name, value)

func set_unsaved_changes(value:bool):
	has_unsaved_changes = value
	var new_text = file_name
	
	if value:
		new_text += "(*)"
	
	parent_category.get_node("VBoxContainer/HSplitContainer/VBoxContainer/ItemList").set_item_text(get_index(), new_text)
