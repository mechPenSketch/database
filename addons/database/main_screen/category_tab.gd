tool
extends Tabs

func update_file_list(dir_path:String):
	var sub_dir = Directory.new()
	#	SUB OPEN ERROR
	var sub_oe = sub_dir.open(dir_path)
	
	match sub_oe:
		OK:
			var le_txt = ""
			sub_dir.list_dir_begin(true)
			var file_name = sub_dir.get_next()
			while file_name != "":
				# IF FILE IS A RESOURCE
				if ".tres" in file_name or ".res" in file_name:
					le_txt += file_name
					le_txt += "\n"
				file_name = sub_dir.get_next()
			sub_dir.list_dir_end()
			$HSplitContainer/LineEdit.set_text(le_txt)
		_:
			print(sub_oe)
