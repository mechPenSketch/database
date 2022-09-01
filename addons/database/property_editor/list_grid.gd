tool
extends GridContainer

var data_type
var property_hint

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

func set_datatype(type, hint):
	data_type = type
	property_hint = hint
	
	var fp_subprop = dir_subprop
	match data_type:
		TYPE_DICTIONARY:
			fp_subprop += "/DictionaryItem.tscn"
		TYPE_INT_ARRAY:
			fp_subprop += "/ArrayItemInt.tscn"
		TYPE_REAL_ARRAY:
			fp_subprop += "/ArrayItemFloat.tscn"
		TYPE_STRING_ARRAY:
			fp_subprop += "/ArrayItemString.tscn"
		TYPE_COLOR_ARRAY:
			fp_subprop += "/ArrayItemColorAlpha.tscn"
		_:
			fp_subprop += "/ArrayItemVar.tscn"
	pkscn_subprop = load(fp_subprop)

# SIGNALS FROM INPUT

func _on_value_changed(v, i, a = current_value):
	a[i] = v
	
	emit_signal("list_changed", current_value)
