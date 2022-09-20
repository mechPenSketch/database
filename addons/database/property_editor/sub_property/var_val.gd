tool
extends VBoxContainer

enum {DT_NULL, DT_BOOL, DT_INT, DT_FLOAT, DT_STRING, DT_COLOR}
var datatypes = { TYPE_BOOL: DT_BOOL,
	TYPE_INT: DT_INT,
	TYPE_REAL: DT_FLOAT,
	TYPE_STRING: DT_STRING,
	TYPE_COLOR: DT_COLOR }
var prev_datatype = DT_NULL

onready var input_string = $LineEdit
onready var input_bool = $CheckBox
onready var input_number = $SpinBox
onready var input_color = $ColorPickerButton

func _value(v):
	var opt_btn = $HBoxContainer/OptionButton
	
	opt_btn.connect("item_selected", self, "_on_datatype_selected")
	
	var type_of = typeof(v)
	var datatype = datatypes[type_of]
	opt_btn.select(datatype)
	
	match datatype:
		DT_BOOL:
			input_bool.set_pressed(v)
		DT_INT, DT_FLOAT:
			input_number.set_value(v)
		DT_STRING:
			input_string.set_text(v)
		DT_COLOR:
			input_string.set_color(v)

func _on_datatype_selected(index):
	unset_datatype(prev_datatype)
	prev_datatype = index
	set_datatype(index)

func unset_datatype(i):
	match i:
		DT_NULL:
			input_string.hide()
		DT_BOOL:
			input_bool.hide()
		DT_INT:
			input_number.hide()
		DT_FLOAT:
			input_number.hide()
		DT_STRING:
			input_string.hide()
		DT_COLOR:
			input_color.hide()
	
func set_datatype(i):
	match i:
		DT_NULL:
			input_string.show()
			input_string.set_text("")
			input_string.set_editable(false)
		DT_BOOL:
			input_bool.show()
		DT_INT:
			input_number.show()
			input_number.set_step(1)
			input_number.set_rounded(true)
		DT_FLOAT:
			input_number.show()
			input_number.set_step(0.001)
			input_number.set_rounded(false)
		DT_STRING:
			input_string.show()
			input_string.set_editable(true)
		DT_COLOR:
			input_color.show()
