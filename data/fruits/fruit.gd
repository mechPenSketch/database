extends Resource

@export var name: String
@export var is_actually_a_veggie: bool
@export var index: int

@export var weight: float = "20.0"
@export var main_color # (Color, RGB)
@export var initial_letter: Resource

@export var flavor_text # (String, MULTILINE)

@export var leaf_type # (String, "Sheet", "Spikey", "Bushy")
enum LEVELS { BASEMENT_1=-1, GROUND, LEVEL_1, LEVEL_2 }
@export var store_level: LEVELS
@export var grown_on # (int, "Underground", "On Ground", "High Sky")

@export var weight_samples # (Array, float)
