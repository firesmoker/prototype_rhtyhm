extends Sprite2D

@export_enum("note", "rest") var type: String = "note"
var path_rest_quarter: String = "res://rest_quarter.png"

func _ready() -> void:
	if type == "rest":
		texture = load(path_rest_quarter)
