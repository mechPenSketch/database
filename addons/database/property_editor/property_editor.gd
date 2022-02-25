tool
extends HBoxContainer

var property_name:String

func set_property(p):
	property_name = p["name"]
	$Name.set_text(property_name.capitalize())
	#print(p)
