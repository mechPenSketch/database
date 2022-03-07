tool
extends MarginContainer

var data_container
var tree_list

const DATA_DIR = "res://data"

const ResourceContainer = preload("Resource.tscn")
var resources_from_ti = {}

func _on_item_selected():
	var tree_item = $VBoxContainer/HSplitContainer/VBoxContainer/Tree.get_selected()
	var resource_index = resources_from_ti[tree_item].get_index()
	$VBoxContainer/HSplitContainer/TabContainer.set_current_tab(resource_index)

func load_data():
	data_container = $VBoxContainer/HSplitContainer/TabContainer
	tree_list = $VBoxContainer/HSplitContainer/VBoxContainer/Tree
	
	var main_dir = Directory.new()
	var open_error = main_dir.open(DATA_DIR)
	
	match open_error:
		OK:
			# GO THROUGH DIRECTORY
			main_dir.list_dir_begin(true, false)
			go_through_folder(main_dir)
		ERR_INVALID_PARAMETER:
			# NEW FOLDER
			main_dir.make_dir("data")
		_:
			print(open_error)

func go_through_folder(dir, parent_ti=null):
	var file_name = dir.get_next()
	while file_name != "":
		
		# IF THE ITEM IS A FOLDER
		if dir.current_is_dir():
			
			# ADD TO TREE
			var category_folder = tree_list.create_item(parent_ti)
			category_folder.set_text(0, file_name.capitalize())
			
			# GO THROUGH SUBFOLDER
			var sub_dir = Directory.new()
			var sub_dir_path = dir.get_current_dir() + "/" + file_name
			var open_error = sub_dir.open(sub_dir_path)
			match open_error:
				OK:
					sub_dir.list_dir_begin(true, false)
					go_through_folder(sub_dir, category_folder)
				_:
					print(open_error)
		
		# OTHERWISE, IF ITEM IS A RESOURCE FILE
		elif ".tres" in file_name or ".res" in file_name:
			
			# ADD TO TREE
			var resource_file = tree_list.create_item(parent_ti)
			resource_file.set_text(0, file_name)
			
			# ADD NEW TAB
			var resource_inst = ResourceContainer.instance()
			data_container.add_child(resource_inst)
			resource_inst.list_properties(self, dir.get_current_dir() + "/" + file_name, file_name)
			
			# LINK BETWEEN TREE ITEM AND RESOURCE
			resources_from_ti[resource_file] = resource_inst
			resource_inst.associated_treeitem = resource_file
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
