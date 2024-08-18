extends Node

# Class to represent a RhythmGameLevel
class_name RhythmGameLevel

# Variable to store the parsed JSON data
var rhythm_game_data: Dictionary = {}

# Initialization function that takes the JSON filename as a parameter
func _init(json_filename: String) -> void:
	load_json_data(json_filename)

# Function to load and parse the JSON file
func load_json_data(json_filename: String) -> void:
	var file: FileAccess = FileAccess.open(json_filename, FileAccess.READ)
	if file:
		var json_text: String = file.get_as_text()
		var json: JSON = JSON.new()
		var json_result: Dictionary = json.parse_string(json_text)
		
		#if json_result.error == OK:
		rhythm_game_data = json_result
		#else:
		#	print("Error parsing JSON: ", json_result.error_string)
		
		file.close()
	else:
		print("File not found: ", json_filename)

# Function to return the data as a list
func get_stages_tmp() -> Array[Dictionary]:
	if "rhythmGameLevel" in rhythm_game_data:
		if "stages" in rhythm_game_data["rhythmGameLevel"]:
			return rhythm_game_data["rhythmGameLevel"]["stages"]
	return []

func get_stages() -> Array[Dictionary]:
	var stages: Array[Dictionary] = []
	if "rhythmGameLevel" in rhythm_game_data:
		if "stages" in rhythm_game_data["rhythmGameLevel"]:
			for stage: Dictionary in rhythm_game_data["rhythmGameLevel"]["stages"]:
				if stage is Dictionary:
					stages.append(stage)
	return stages
	

func get_stages_number() -> int: 
	return get_stages().size()
	
# Optional: Function to return a specific stage by stage number
func get_stage(stage_number: int) -> Dictionary:
	#var stages: Array[Dictionary] = get_stages()  # Specify the type of items in the array
	var stages: Array[Dictionary] = get_stages() as Array[Dictionary]

	for stage in stages:
		if stage["stageNumber"] == stage_number:
			return stage
	return {}
