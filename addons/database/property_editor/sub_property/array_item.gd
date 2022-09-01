tool
extends HBoxContainer

signal value

func set_item(i, val):
	$Index.set_text(String(i))
	emit_signal("value", i, val)
