tool
extends HBoxContainer

func set_key(k):
	var opt_btn = $Key/HBoxContainer/OptionButton
	
	match typeof(k):
		TYPE_STRING:
			opt_btn.select(4)
			
			var input = $Key/LineEdit
			input.set_editable(true)
			input.set_text(k)
		TYPE_INT, TYPE_REAL:
			$Key/LineEdit.hide()
			
			var input = $Key/SpinBox
			input.show()
			input.set_value(k)
			
			if typeof(k) == TYPE_INT:
				opt_btn.select(2)
				input.set_rounded(true)
			else:
				opt_btn.select(3)
		TYPE_BOOL:
			opt_btn.select(1)
			
			$Key/LineEdit.hide()
			
			var input = $Key/CheckBox
			input.show()
			input.set_pressed(k)
		TYPE_COLOR:
			opt_btn.select(5)
			
			$Key/LineEdit.hide()
			
			var input = $Key/ColorPickerButton
			input.show()
			input.set_color(k)

func set_value(v):
	$Value._value(v)
