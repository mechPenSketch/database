tool
extends HBoxContainer

func set_property(p):
	$Name.set_text(p["name"].capitalize())
	print(p)
