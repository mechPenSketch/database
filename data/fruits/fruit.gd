extends Resource

export(String) var name
export(bool) var is_actually_a_veggie
export(int) var index

export(float) var weight = "20.0"
export(Color, RGB) var main_color
export(Resource) var initial_letter

export(String, MULTILINE) var flavor_text

export(String, "Sheet", "Spikey", "Bushy") var leaf_type
enum LEVELS { BASEMENT_1=-1, GROUND, LEVEL_1, LEVEL_2 }
export(LEVELS) var store_level
export(int, "Underground", "On Ground", "High Sky") var grown_on

export(Array, float) var weight_samples
