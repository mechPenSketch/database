tool
extends ScrollContainer

# COMPARING PROPERT INSPECTOR
# 	@@3851 is the EditorInspector

var parent_category
var file_name

const base_dir = "res://addons/database/property_editor/"
const extension = ".tscn"

var associated_resource
var associated_script
var has_unsaved_changes:bool setget set_unsaved_changes

func list_properties(category, filepath:String, fn):
	parent_category = category
	file_name = fn
	
	associated_resource = ResourceLoader.load(filepath)
	associated_script = associated_resource.get_script()
	for pl in associated_script.get_script_property_list():
		# THE PROPERTY SHOULD BE ABLE TO BE STORED
		if pl["usage"] % 2 == PROPERTY_USAGE_STORAGE:
			var pe_type = get_pe_by_type(pl)
			# PROPERTY EDITOR
			var pe = load(base_dir + pe_type + extension)
			var pe_inst = pe.instance()
			pe_inst.set_property(pl)
			$VBoxContainer.add_child(pe_inst)
			
			# VALUE
			var value = associated_resource.get(pl["name"])
			match pe_type:
				"String":
					var line_edit = pe_inst.get_node("LineEdit")
					line_edit.connect("text_entered", self, "_on_value_entered", [pe_inst.get_index()])
					
					if value:
						line_edit.set_text(value)

func get_pe_by_type(property):
	match property["type"]:
		_:
			return "String"

func _on_value_entered(value, child_index):
	var property_name = $VBoxContainer.get_child(child_index).property_name
	if value != associated_resource.get(property_name):
		set_unsaved_changes(true)

func set_unsaved_changes(value:bool):
	has_unsaved_changes = value
	var new_text = file_name
	
	if value:
		new_text += "(*)"
	
	parent_category.get_node("VBoxContainer/HSplitContainer/VBoxContainer/ItemList").set_item_text(get_index(), new_text)
