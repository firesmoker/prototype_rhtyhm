class_name Note extends Sprite2D

@export_enum("note", "rest") var type: String = "note"
var duration: float = 1.0
var path_rest_quarter: String = "res://rest_quarter.png"

func _ready() -> void:
	if type == "rest":
		texture = load(path_rest_quarter)


# Setter function for the type attribute
func set_type(value: String) -> void:
	type = value
	load_image_for_type(type)
	
func set_type_and_duration(typeValue: String, durationValue: float) -> void:
	type = typeValue
	duration = durationValue
	load_image_for_type(type, duration)


# Function to load and display an image based on the type
func load_image_for_type(image_type: String, duration: float = 1.0) -> void:
	var image_path: String = ""
	match image_type:
		"rest":
			image_path = path_rest_quarter
		"note":
			if duration == 1.0: 
				image_path = "res://quarter-note.png"
			else:
				image_path = "res://eigth-note.png"
		_:
			image_path = "res://quarter-note.png"
	texture = load(image_path)

