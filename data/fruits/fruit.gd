extends Resource

@export var name: String
@export var is_actually_a_veggie: bool
@export var index: int

@export var weight: float = 20.0
@export var main_color: Color
@export var initial_letter: Resource

@export_multiline var flavor_text: String

@export_enum("Sheet", "Spikey", "Bushy") var leaf_type: String
enum LEVELS { BASEMENT_1=-1, GROUND, LEVEL_1, LEVEL_2 }
@export var store_level: LEVELS
@export_enum("Underground", "On Ground", "High Sky") var grown_on: int

@export var weight_samples: Array[float]
