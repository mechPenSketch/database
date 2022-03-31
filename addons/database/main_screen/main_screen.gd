tool
extends MarginContainer

var editor_plugin

onready var data_container = $VBoxContainer/HSplitContainer/TabContainer
onready var tree_list = $VBoxContainer/HSplitContainer/VBoxContainer/Tree

const DATA_DIR = "res://data"

var icon_folder
var icon_resource

const ResourceContainer = preload("Resource.tscn")
var filename_to_rindx = {} # RINDX: RESOURCE (CHILD) INDEX
enum {TICOL_FILENAME}

onready var newcat_name = $NewCategory/VBoxContainer/LineEdit
onready var newres_name = $NewResource/VBoxContainer/Name/HBoxContainer/LineEdit
onready var res_cat_options = $NewResource/VBoxContainer/Category/OptionButton
signal changing_filesystem

var cat_config = {}

var selected_resoptions
onready var empty_options = $EmptyResourceOptions
onready var resource_options = $ResourceOptions
enum {OPT_NEW, OPT_NEWAS, OPT_LOAD, OPT_INSTALOAD, OPT_CAT, OPT_EDIT, OPT_CLEAR, OPT_SHOWINFOLDER, OPT_SHOWINCAT}

func _option_pressed_by_id(id):
	item_id_effect(selected_resoptions, id)

func _newcat_pressed():
	$NewCategory.popup_centered()
	
	# FOCUS ON INPUT
	newcat_name.grab_focus()
	
func _newres_pressed():
	$NewResource.popup_centered()
	
	# FOCUS ON INPUT
	newres_name.grab_focus()

func _newcat_confirmed():
	var base_dir = Directory.new()
	var open_error = base_dir.open(DATA_DIR)
	
	var new_folder_name = newcat_name.get_text()
	
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
	
	# EMPTY INPUT
	newcat_name.set_text("")
	
	emit_signal("changing_filesystem")

func _newres_confirmed():
	var base_dir = Directory.new()
	var open_error = base_dir.open(DATA_DIR.plus_file(res_cat_options.get_item_text(res_cat_options.get_selected())))
	
	var newres_name_ext = newres_name.get_text() + ".tres"
	
	if base_dir.file_exists(newres_name_ext):
		$Duplicate.popup_centered()
	else:
		var full_path = base_dir.get_current_dir().plus_file(newres_name_ext)
		var new_res = Resource.new()
		
		# SETTING SCRIPT
		var new_script = load(base_dir.get_current_dir().plus_file("category.gd"))
		new_res.set_script(new_script)
		
		ResourceSaver.save(full_path, new_res)
	
	# EMPTY INPUT
	newres_name.set_text("")
	
	emit_signal("changing_filesystem")

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

func add_options_to_popup(popup, has_value=false):
	var editor_control = editor_plugin.get_editor_interface().get_base_control()
	
	popup.add_icon_item(icon_folder, "Limit to Category", OPT_CAT)
	if has_value:
		var icon_edit = editor_control.get_icon("Edit", "EditorIcons")
		popup.add_icon_item(icon_edit, "Edit", OPT_EDIT)
		var icon_clear = editor_control.get_icon("Clear", "EditorIcons")
		popup.add_icon_item(icon_clear, "Clear", OPT_CLEAR)
		
		popup.add_separator()
		
		popup.add_item("Show in Filesystem")
		popup.add_item("Show in Datasystem")

func update_tree(search:String = ""):
	# UNLINK TREE ITEM FROM RESOURCES
	for c in data_container.get_children():
		c.associated_treeitem = null
		
	tree_list.clear()
	res_cat_options.clear()
	
	var main_dir = Directory.new()
	var open_error = main_dir.open(DATA_DIR)
	
	match open_error:
		OK:
			# GO THROUGH DIRECTORY
			main_dir.list_dir_begin(true, false)
			go_through_folder_for_update(main_dir, search,  tree_list.create_item())
			for c in data_container.get_children():
				c.update_property_options()
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
			
			# ADD TO NEW RESOURCE > CATEGORY
			var sub_dir_path = dir.get_current_dir().plus_file(file_name)
			var folder_name = sub_dir_path.trim_prefix(DATA_DIR + "/")
			res_cat_options.add_item(folder_name)
			
			# GO THROUGH SUBFOLDER
			var sub_dir = Directory.new()
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
			
				# IF HAVEN'T ALREADY, ADD NEW TAB
				if not file_name in filename_to_rindx.keys():
					var resource_inst = ResourceContainer.instance()
					resource_inst.set_editor_plugin(editor_plugin)
					data_container.add_child(resource_inst)
					resource_inst.list_properties(self, dir.get_current_dir(), file_name)
					
					filename_to_rindx[file_name] = resource_inst.get_index()
			
				# LINK BETWEEN TREE ITEM AND RESOURCE
				var rindx = filename_to_rindx[file_name]
				var resource = data_container.get_child(rindx)
				resource.associated_treeitem = resource_file
		
		# ALTERNATIVELY, IF FILE IS CONFIG FILE
		elif file_name == "config.cfg":
			var cat_path = dir.get_current_dir()
			if !cat_path in cat_config.keys():
				var config = ConfigFile.new()
				config.load(dir.get_current_dir().plus_file(file_name))
				cat_config[cat_path] = config
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
func item_id_effect(options_node, id):
	match id:
		OPT_NEW:
			print("New res")
		OPT_NEWAS:
			print("New res As...")
		OPT_LOAD:
			print("Open Filesystem")
		OPT_CAT:
			print("Pick a Category")
		OPT_EDIT:
			print("Goto res")
		OPT_CLEAR:
			options_node.clear_value()

func set_editor_plugin(node):
	editor_plugin = node
	
	# ICONS
	var editor_control = editor_plugin.get_editor_interface().get_base_control()
	#	SEARCH
	$VBoxContainer/HSplitContainer/VBoxContainer/Search.set_right_icon(editor_control.get_icon("Search", "EditorIcons"))
	
	#	FOLDERS AND RESOURCES
	icon_folder = editor_control.get_icon("Folder", "EditorIcons")
	icon_resource = editor_control.get_icon("ResourcePreloader", "EditorIcons")
	
	# USING EDITOR PLUGIN TO ADD ONTO RESOURCE OPTIONS
	add_options_to_popup(empty_options)
	empty_options.set_as_minsize()
	add_options_to_popup(resource_options, true)
	resource_options.set_as_minsize()
