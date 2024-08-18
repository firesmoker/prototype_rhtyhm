class_name GameManager extends Node
@onready var points_text: Label = $"../HUD/PointsText"
@onready var instruction: Label = $"../HUD/Instruction"
@onready var notes_container: Node2D = $"../Notes"

@onready var pointer: Sprite2D = $"../Pointer"
@onready var pointer_ai: Sprite2D = $"../Pointer_AI"
@onready var background: Sprite2D = $"../Background"

@export var note_nodes: Array[Note]
@export var note_y_location: float = -40
@export var note_quarter_gap: float = 300
@export var note_visual_offset: float = 100
@export var tempo: float = 120 # in BPM
@export var points: int = 0
@export var points_per_note: float = 10

@export var miss_color: Color = Color.RED
@export var success_color: Color = Color.TURQUOISE

var stage_index: int = 0
var original_note_scale: Vector2 = Vector2(0.281,0.281)
enum note_status {IDLE,ACTIVE,PLAYED,MISSED}

var finished_round: bool = false
var notes_dictionary: Dictionary
var four_quarters_bar_duration: float = 2
var quarter_note_duration: float = 0.5  # Duration of a quarter note in seconds (120 BPM)
var elapsed_time: float = 0.0
var beat_time: float = 0
var beat_num: int = -1
var taking_input: bool = false
var current_note_num: int = 0
var note_highlight_offset: float = 10
var sfx_player: AudioStreamPlayer
var NoteScene: PackedScene = preload("res://scenes/note.tscn")
signal beat_signal
signal notes_populated_signal



func load_rhythmic_pattern_level() -> void:
	
	notes_dictionary.clear()
	#populate_note_nodes()
	var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://rhythmGameLevelExampleLevel2.json")
	stage_index = (stage_index % rhythm_game_level.get_stages_number()) + 1
	print("load new rhythmic pattern for stage ", stage_index)
	var stage: Dictionary = rhythm_game_level.get_stage(stage_index)
	# Assuming stages["notes"] contains the list of notes
	var input_notes: Array[Dictionary] = []
	if "notes" in stage:
		for note: Dictionary in stage["notes"]:
			input_notes.append(note)
			
	populate_note_nodes(input_notes.size())
			
	for i in range(input_notes.size()):
		var type: String  = "note"
		if input_notes[i]["is_rest"]:
			type = "rest"
		if i == 0:
			notes_dictionary[i] = {
				"x_location": 0,
				"duration": input_notes[i]["duration"],  # Assuming all are quarter notes, adjust as needed
				"type": type,
				"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
		}
		else:
			notes_dictionary[i] = {
				"x_location": notes_dictionary[i-1]["x_location"] + note_quarter_gap * input_notes[i-1]["duration"],
				"duration": input_notes[i]["duration"],  # Assuming all are quarter notes, adjust as needed
				"type": type,
				"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
			}
		print("duration for note is: " + str(input_notes[i]["duration"]))
		note_nodes[i].set_type(type)
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note in note_nodes:
		note.position.x = notes_dictionary[count]["x_location"]
		note.position.y = note_y_location
		count += 1
	print(notes_dictionary)
	
	
	
func _ready() -> void:
	
	#populate_note_nodes()
	sfx_player = MusicPlayer.get_child(0)
	if not MusicPlayer.playing:
		MusicPlayer.play()
	four_quarters_bar_duration = 60 / tempo * 4
	quarter_note_duration = 60 / tempo
	var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://rhythmGameLevelExample.json")
	var stages: Dictionary = rhythm_game_level.get_stage(1)
	# Assuming stages["notes"] contains the list of notes
	var input_notes: Array[Dictionary] = []
	if "notes" in stages:
		for note: Dictionary in stages["notes"]:
			input_notes.append(note)
			
	populate_note_nodes(input_notes.size())	
	for i in range(input_notes.size()):
		var type: String  = "note"
		if input_notes[i]["is_rest"]:
			type = "rest"
		notes_dictionary[i] = {
			"x_location": i * note_quarter_gap,
			"duration": 1,  # Assuming all are quarter note, adjust as needed
			"type": type,
			"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
		}
		note_nodes[i].type = type
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note in note_nodes:
		note.position.x = notes_dictionary[count]["x_location"]
		note.position.y = note_y_location
		count += 1
	
	elapsed_time = 0.0
	beat_time = 0 + MusicPlayer.beat_offset
	
	print(notes_dictionary)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("play"):
		sfx_player.stream = MusicPlayer.player_hit_sound
		sfx_player.play()
		if taking_input:
			if current_note_num < notes_dictionary.size():
				if notes_dictionary[current_note_num]["status"] == note_status.ACTIVE:
					if note_nodes[current_note_num].type != "rest":
						notes_dictionary[current_note_num]["status"] = note_status.PLAYED
						pointer.modulate = Color.GREEN # TEMPORARY
						var current_note_location: float = notes_dictionary[current_note_num]["x_location"]
						var accuracy: float = Vector2(current_note_location, note_y_location).distance_to(Vector2(pointer.position.x, note_y_location))
						accuracy = (1 - accuracy / note_visual_offset) * 100
						var penalty: int = int(4 - accuracy / (100 / 4)) * 4
						print(accuracy)
						print(penalty)
						note_nodes[current_note_num].material.set_shader_parameter("color", success_color * (1 - (penalty * 0.05)))
						points += points_per_note - penalty
						points_text.text = "Points: " + str(points)
						print("yay")
						taking_input = false
					else:
						pointer.modulate = Color.RED # TEMPORARY
						points -= 500
						points_text.text = "Points: " + str(points)
						pointer.modulate = Color.RED
				
		else:
			pointer.modulate = Color.RED
			points -= points_per_note / 3
			points_text.text = "Points: " + str(points)
			print("you suck")

func _process(delta: float) -> void:
	elapsed_time += delta  # Accumulate time
	beat_time += delta
	if beat_time >= quarter_note_duration:
		#print("beat")
		emit_signal("beat_signal")
		beat_num += 1
		beat_time -= quarter_note_duration 
	if taking_input and current_note_num < notes_dictionary.size(): # TEMPORARY
		if notes_dictionary[current_note_num]["status"] == note_status.PLAYED:
			pointer.modulate = Color.GREEN # TEMPORARY
	else: # TEMPORARY
		pointer.modulate = Color.WHITE # TEMPORARY
		
	bar_loop()

func bar_loop() -> void:
	#print("current_note_num, notes_dictionary.size():  ",current_note_num, notes_dictionary.size())
	if current_note_num < notes_dictionary.size():
		var offset: float = note_visual_offset * notes_dictionary[current_note_num]["duration"]
		var current_note_x_position: float = notes_dictionary[current_note_num]["x_location"]
		if pointer.position.x >= current_note_x_position - offset and pointer.position.x <= current_note_x_position + offset:
			taking_input = true
		elif pointer.position.x >= current_note_x_position + note_visual_offset:
			if notes_dictionary[current_note_num]["status"] != note_status.PLAYED:
				if not notes_dictionary[current_note_num]["type"] == "rest":
					notes_dictionary[current_note_num]["status"] != note_status.MISSED
					note_nodes[current_note_num].material.set_shader_parameter("color", miss_color)
				else:
					notes_dictionary[current_note_num]["status"] != note_status.PLAYED
					note_nodes[current_note_num].material.set_shader_parameter("color", success_color)
			current_note_num += 1
			if current_note_num < notes_dictionary.size():
				notes_dictionary[current_note_num]["status"] = note_status.ACTIVE
		else:
			taking_input = false
		
	else:
		taking_input = false
		if points >= 30 and not finished_round:
			print("you win!")
			finished_round = true
			print("RESTART!")
		elif not finished_round:
			print("you lose")
			finished_round = true
			print("RESTART!")
		await beat_signal
		if finished_round:
			restart_level()
			finished_round = false
		

func pulse(note_num: int) -> void:
	note_nodes[note_num].scale = original_note_scale * 1.25
	note_nodes[note_num].position.y -= note_highlight_offset
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.start()
	await timer.timeout
	#print("timer stopped")
	note_nodes[note_num].scale = original_note_scale
	note_nodes[note_num].position.y += note_highlight_offset

func restart_level() -> void:
	#populate_note_nodes()
	load_rhythmic_pattern_level()
	#if instruction.text == "Listen...":
		#instruction.text = "Play!"
	#else:
		#instruction.text = "Listen..."
	points = 0
	points_text.text = "Points: " + str(points)
	current_note_num = 0
	notes_dictionary[0]["status"] = note_status.ACTIVE
	pointer.start_position = pointer.restart_position
	pointer.target_position = pointer.restart_target_position
	pointer.position = pointer.start_position
	
	pointer_ai.start_position = pointer_ai.restart_position
	pointer_ai.target_position = pointer_ai.restart_target_position
	pointer_ai.position = pointer_ai.start_position
	
	elapsed_time = 0
	
func populate_note_nodes(number_of_notes: int = 4) -> void:
	note_nodes.clear()
	for n: Node in notes_container.get_children():
		notes_container.remove_child(n)
		n.queue_free()
		
	print(note_nodes.size())
	for i: int in range(number_of_notes):
		var instance: Note = NoteScene.instantiate() as Note
		notes_container.add_child(instance)
		note_nodes.append(instance)
	emit_signal("notes_populated_signal")
