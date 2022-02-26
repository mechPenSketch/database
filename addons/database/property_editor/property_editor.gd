tool
extends HBoxContainer

var property_name:String
var file_name:String

var prev_val

func set_property(p):
	property_name = p["name"]
	$Name.set_text(property_name.capitalize())
	#print(p)
