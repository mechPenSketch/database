tool
extends Tabs

export(Texture) var default_item_icon

# COMPARING SCRIPT EDITOR
# 	@@6519, which lists gdscript files, is an ItemList.
# 	@@6534, which is the space that directly edit scripts, is a TabContainer.

const ResourceContainer = preload("Resource.tscn")

func update_file_list(dir_path:String):
	var sub_dir = Directory.new()
	#	SUB OPEN ERROR
	var sub_oe = sub_dir.open(dir_path)
	
	match sub_oe:
		OK:
			sub_dir.list_dir_begin(true)
			var file_name = sub_dir.get_next()
			while file_name != "":
				# IF FILE IS A RESOURCE
				if ".tres" in file_name or ".res" in file_name:
					$VBoxContainer/HSplitContainer/VBoxContainer/ItemList.add_item(file_name, default_item_icon)
					
					# ADD NEW TAB
					var resource_inst = ResourceContainer.instance()
					$VBoxContainer/HSplitContainer/TabContainer.add_child(resource_inst)
					resource_inst.list_properties(self, dir_path + "/" + file_name, file_name)
				file_name = sub_dir.get_next()
			sub_dir.list_dir_end()
		_:
			print(sub_oe)

func _on_item_activated(i):
	$VBoxContainer/HSplitContainer/TabContainer.set_current_tab(i)

func save_resource():
	var tab_container = $VBoxContainer/HSplitContainer/TabContainer
	tab_container.get_child(tab_container.get_current_tab()).save_resource()

func save_all():
	for c in $VBoxContainer/HSplitContainer/TabContainer:
		if c.has_unsaved_changes:
			c.save_resource()
