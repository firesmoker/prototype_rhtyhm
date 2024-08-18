class_name GameManager extends Node
@onready var points_text: Label = $"../HUD/PointsText"
@onready var instruction: Label = $"../HUD/Instruction"

@onready var pointer: Sprite2D = $"../Pointer"
@onready var pointer_ai: Sprite2D = $"../Pointer_AI"
@onready var background: Sprite2D = $"../Background"

@export var notes: Array[Node2D]
@export var note_y_location: float = -40
@export var note_quarter_gap: float = 300
@export var note_visual_offset: float = 100
@export var tempo: float = 120 # in BPM
@export var points: int = 0
@export var points_per_note: float = 10
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

signal beat_signal



func load_rhythmic_pattern_level() -> void:
	var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://rhythmGameLevelExampleLevel2.json")
	var stages: Dictionary = rhythm_game_level.get_stage(1)
	# Assuming stages["notes"] contains the list of notes
	var input_notes: Array[Dictionary] = []
	if "notes" in stages:
		for note: Dictionary in stages["notes"]:
			input_notes.append(note)
			
			
	for i in range(input_notes.size()):
		var type: String  = "note"
		if input_notes[i]["is_rest"]:
			type = "rest"
		notes_dictionary[i] = {
			"x_location": i * note_quarter_gap,
			"duration": "quarter",  # Assuming all are quarter notes, adjust as needed
			"type": type,
			"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
		}
		notes[i].set_type(type)
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note in notes:
		note.position.x = notes_dictionary[count]["x_location"]
		note.position.y = note_y_location
		count += 1
	print(notes_dictionary)
	
	
	
func _ready() -> void:
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
			
			
	for i in range(input_notes.size()):
		var type: String  = "note"
		if input_notes[i]["is_rest"]:
			type = "rest"
		notes_dictionary[i] = {
			"x_location": i * note_quarter_gap,
			"duration": "quarter",  # Assuming all are quarter notes, adjust as needed
			"type": type,
			"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
		}
		notes[i].type = type
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note in notes:
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
					if notes[current_note_num].type != "rest":
						notes_dictionary[current_note_num]["status"] = note_status.PLAYED
						pointer.modulate = Color.GREEN # TEMPORARY
						var current_note_location: float = notes_dictionary[current_note_num]["x_location"]
						var accuracy: float = Vector2(current_note_location, note_y_location).distance_to(Vector2(pointer.position.x, note_y_location))
						accuracy = (1 - accuracy / note_visual_offset) * 100
						var penalty: int = int(4 - accuracy / (100 / 4)) * 4
						print(accuracy)
						print(penalty)
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
	if current_note_num < notes_dictionary.size():
		var current_note_x_position: float = notes_dictionary[current_note_num]["x_location"]
		if pointer.position.x >= current_note_x_position - note_visual_offset and pointer.position.x <= current_note_x_position + note_visual_offset:
		#if pointer.position.x >= current_note_x_position - note_visual_offset / 2 and pointer.position.x <= current_note_x_position + note_visual_offset:
			#if not taking_input and notes_dictionary[current_note_num]["status"] == note_status.ACTIVE:
				#if notes[current_note_num].type != "rest":
					#notes[current_note_num].scale = original_note_scale * 1.25
					#notes[current_note_num].position.y -= note_highlight_offset
			taking_input = true
		elif pointer.position.x >= current_note_x_position + note_visual_offset:
			#if notes[current_note_num].type != "rest":
				#notes[current_note_num].scale = original_note_scale
				#notes[current_note_num].position.y += note_highlight_offset
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
		elif not finished_round:
			print("you lose")
			finished_round = true
		await beat_signal
		restart_level()

func pulse(note_num: int) -> void:
	notes[note_num].scale = original_note_scale * 1.25
	notes[note_num].position.y -= note_highlight_offset
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.start()
	await timer.timeout
	print("timer stopped")
	notes[note_num].scale = original_note_scale
	notes[note_num].position.y += note_highlight_offset

func restart_level() -> void:
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
