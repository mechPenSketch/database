tool
extends ScrollContainer

# COMPARING PROPERT INSPECTOR
# 	@@3851 is the EditorInspector

func list_properties(filepath:String):
	var resource = ResourceLoader.load(filepath)
	var script = resource.get_script()
	for pl in script.get_script_property_list():
		# THE PROPERTY SHOULD BE ABLE TO BE STORED
		if pl["usage"] % 2 == PROPERTY_USAGE_STORAGE:
			var pe = load("res://addons/database/property_editor/String.tscn")
			var pe_inst = pe.instance()
			pe_inst.set_property(pl)
			$VBoxContainer.add_child(pe_inst)
