tool
extends VBoxContainer

func _value(v):
	var opt_btn = $OptionButton
	
	match typeof(v):
		TYPE_BOOL:
			opt_btn.select(1)
			
			$LineEdit.hide()
			
			var input = $CheckBox
			input.show()
			input.set_pressed(v)
		TYPE_INT, TYPE_REAL:
			$LineEdit.hide()
			
			var input = $SpinBox
			input.show()
			input.set_value(v)
			
			if typeof(v) == TYPE_INT:
				opt_btn.select(2)
				input.set_rounded(true)
			else:
				opt_btn.select(3)
		TYPE_STRING:
			opt_btn.select(4)
			
			var input = $LineEdit
			input.set_editable(true)
			input.set_text(v)
		TYPE_COLOR:
			opt_btn.select(5)
			
			$LineEdit.hide()
			
			var input = $ColorPickerButton
			input.show()
			input.set_color(v)
