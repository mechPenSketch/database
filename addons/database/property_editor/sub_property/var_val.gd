tool
extends VBoxContainer

func _value(v):
	match typeof(v):
		TYPE_STRING:
			var input = $LineEdit
			input.set_editable(true)
			input.set_text(v)
		TYPE_INT, TYPE_REAL:
			$LineEdit.hide()
			var input = $SpinBox
			input.show()
			input.set_rounded(typeof(v) == TYPE_INT)
			input.set_value(v)
		TYPE_COLOR:
			$LineEdit.hide()
			var input = $ColorPickerButton
			input.show()
			input.set_color(v)
