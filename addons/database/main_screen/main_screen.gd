tool
extends MarginContainer

onready var data_container = $VBoxContainer/HSplitContainer/TabContainer
onready var tree_list = $VBoxContainer/HSplitContainer/VBoxContainer/Tree

const DATA_DIR = "res://data"

export(Texture) var icon_folder
export(Texture) var icon_resource

const ResourceContainer = preload("Resource.tscn")
var filename_to_rindx = {} # RINDX: RESOURCE (CHILD) INDEX
enum {TICOL_FILENAME}

func _newcat_pressed():
	$NewCategory.popup_centered()
	
func _newres_pressed():
	print("new resource")

func _newcat_confirmed():
	var base_dir = Directory.new()
	var open_error = base_dir.open(DATA_DIR)
	
	var new_folder_name = $NewCategory/VBoxContainer/LineEdit.get_text()
	
	if base_dir.dir_exists(new_folder_name):
		$Duplicate.popup_centered()
	else:
		base_dir.make_dir(new_folder_name)
		
		# ADD SCRIPT
		var new_filepath = DATA_DIR.plus_file(new_folder_name).plus_file("category.gd")
		var file = File.new()
		file.open(new_filepath, File.WRITE)
		file.store_string("extends Resource")
		file.close()

func _on_filesystem_changed():
	var search_text = $VBoxContainer/HSplitContainer/VBoxContainer/Search.get_text()
	update_tree()

func _on_item_selected():
	var tree_item = tree_list.get_selected()
	var selected_filename = tree_item.get_text(TICOL_FILENAME)
	if selected_filename in filename_to_rindx.keys():
		var resource_index = filename_to_rindx[selected_filename]
		data_container.set_current_tab(resource_index)

func _on_search_changed(new_text):
	update_tree(new_text)

func load_data():
	var main_dir = Directory.new()
	var open_error = main_dir.open(DATA_DIR)
	
	match open_error:
		OK:
			# GO THROUGH DIRECTORY
			main_dir.list_dir_begin(true, false)
			go_through_folder(main_dir, tree_list.create_item())
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
			category_folder.set_icon(TICOL_FILENAME, icon_folder)
			category_folder.set_text(TICOL_FILENAME, file_name)
			
			# GO THROUGH SUBFOLDER
			var sub_dir = Directory.new()
			var sub_dir_path = dir.get_current_dir().plus_file(file_name)
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
			resource_file.set_icon(TICOL_FILENAME, icon_resource)
			resource_file.set_text(TICOL_FILENAME, file_name)
			
			# ADD NEW TAB
			var resource_inst = ResourceContainer.instance()
			data_container.add_child(resource_inst)
			resource_inst.list_properties(self, dir.get_current_dir() + "/" + file_name, file_name)
			
			# LINK BETWEEN TREE ITEM AND RESOURCE
			filename_to_rindx[file_name] = resource_inst.get_index()
			resource_inst.associated_treeitem = resource_file
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

func update_tree(search:String = ""):
	# UNLINK TREE ITEM FROM RESOURCES
	for c in data_container.get_children():
		c.associated_treeitem = null
		
	tree_list.clear()
	
	var main_dir = Directory.new()
	var open_error = main_dir.open(DATA_DIR)
	
	match open_error:
		OK:
			# GO THROUGH DIRECTORY
			main_dir.list_dir_begin(true, false)
			go_through_folder_for_update(main_dir, search,  tree_list.create_item())
		ERR_INVALID_PARAMETER:
			print("missing data folder")
		_:
			print(open_error)

func go_through_folder_for_update(dir, search, parent_ti=null):
	var file_name = dir.get_next()
	while file_name != "":
		
		var matched = !search or search in file_name
		
		# IF THE ITEM IS A FOLDER
		if dir.current_is_dir():
			
			# ADD TO TREE
			var category_folder = tree_list.create_item(parent_ti)
			category_folder.set_icon(TICOL_FILENAME, icon_folder)
			category_folder.set_text(TICOL_FILENAME, file_name)
			
			# GO THROUGH SUBFOLDER
			var sub_dir = Directory.new()
			var sub_dir_path = dir.get_current_dir() + "/" + file_name
			var open_error = sub_dir.open(sub_dir_path)
			match open_error:
				OK:
					sub_dir.list_dir_begin(true, false)
					go_through_folder_for_update(sub_dir, search, category_folder)
				_:
					print(open_error)
					
			# REMOVING FOLDER
			if not (matched or category_folder.get_children()):
				category_folder.free()
		
		# OTHERWISE, IF ITEM IS A RESOURCE FILE
		elif ".tres" in file_name or ".res" in file_name:
			
			if matched:
			# ADD TO TREE
				var resource_file = tree_list.create_item(parent_ti)
				resource_file.set_icon(TICOL_FILENAME, icon_resource)
				resource_file.set_text(TICOL_FILENAME, file_name)
			
				# LINK BETWEEN TREE ITEM AND RESOURCE
				var rindx = filename_to_rindx[file_name]
				var resource = data_container.get_child(rindx)
				resource.associated_treeitem = resource_file
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
