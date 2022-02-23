tool
extends Tabs

# COMPARED WITH SCRIPT EDITOR
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
					$HSplitContainer/VBoxContainer/ItemList.add_item(file_name)
				file_name = sub_dir.get_next()
			sub_dir.list_dir_end()
		_:
			print(sub_oe)
