extends Control
@onready var grid: GridContainer = $Grid
@export var level_button_template: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var json_files: Array = get_json_files_from_folder("res://levels")
	for json: String in json_files:
		var new_level_button: TextureButton = level_button_template.instantiate()
		new_level_button.level_name = json.trim_suffix(".json")
		grid.add_child(new_level_button)
	#pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_json_files_from_folder(folder_path: String) -> Array:
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot open folder: %s" % folder_path)
		return []
	
	var json_files := []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			json_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	return json_files
