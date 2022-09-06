tool
extends GridContainer

var data_type
var property_hint
var hint_string

export(String, DIR) var dir_subprop
var pkscn_subprop

var current_value
signal list_changed

func list_items(val):
	current_value = val
	
	if val:
		if data_type == TYPE_DICTIONARY:
			for k in val.keys():
				var item = pkscn_subprop.instance()
				add_child(item)
				item.set_key(k)
				item.set_value(val[k])
		else:
			for i in val.size():
				var item = pkscn_subprop.instance()
				add_child(item)
				item.set_item(i, val[i])

func set_datatype(type, hint, h_string):
	data_type = type
	property_hint = hint
	hint_string = h_string
	
	var fp_subprop = dir_subprop
	# property_hint: int
	##	0: no further export hints
	##	26: float, String etc
	
	# hint_string: String
	## "2:" int
	## "3:" float
	## "4:" String
	if data_type == TYPE_DICTIONARY:
		fp_subprop += "/DictionaryItem.tscn"
	else:
		fp_subprop += "/ArrayItem"
		if property_hint:
			match hint_string:
				"2:":
					fp_subprop += "Int"
				"3:":
					fp_subprop += "Float"
				"4:":
					fp_subprop += "String"
				"5:":
					fp_subprop += "ColorAlpha"
		else:
			fp_subprop += "Var"
		fp_subprop += ".tscn"
	
	pkscn_subprop = load(fp_subprop)

# SIGNALS FROM INPUT

func _on_value_changed(v, i, a = current_value):
	a[i] = v
	
	emit_signal("list_changed", current_value)
