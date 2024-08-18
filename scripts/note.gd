class_name Note extends Sprite2D

@export_enum("note", "rest") var type: String = "note"
var path_rest_quarter: String = "res://rest_quarter.png"

func _ready() -> void:
	if type == "rest":
		texture = load(path_rest_quarter)


# Setter function for the type attribute
func set_type(value: String) -> void:
	type = value
	load_image_for_type(type)
	
	
# Function to load and display an image based on the type
func load_image_for_type(image_type: String) -> void:
	var image_path: String = ""
	match image_type:
		"rest":
			image_path = path_rest_quarter
		"Quarter":
			image_path = "res://quarter-note.png"
		_:
			image_path = "res://quarter-note.png"
	texture = load(image_path)

