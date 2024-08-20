class_name GameManager extends Node

@onready var points_text: Label = $"../HUD/PointsText"
@onready var instruction: Label = $"../Background/Instruction"
@onready var notes_container: Node2D = $"../Notes"
@onready var background: ColorRect = $"../Background/ColorRect"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var progress_bar: ProgressBar = $"../HUD/ProgressBar"
@onready var beat_overlay: ColorRect = $"../Background/BeatOverlay"

@onready var listen: Sprite2D = $"../Listen"

@onready var pointer: Sprite2D = $"../Pointer"
@onready var pointer_ai: Sprite2D = $"../Pointer_AI"
@onready var star_1: Sprite2D = $"../HUD/Star1"
@onready var star_2: Sprite2D = $"../HUD/Star2"
@onready var star_3: Sprite2D = $"../HUD/Star3"




@export var note_nodes: Array[Note]
@export var note_y_location: float = -40
@export var note_quarter_gap: float = 300
@export var note_visual_offset: float = 100
@export var tempo: float = 120 # in BPM
@export var points: int = 0
@export var level_points: int = 0
@export var points_per_note: float = 10

@export var background_color_listen: Color = Color.DARK_SLATE_BLUE
@export var background_color_play: Color = Color.MEDIUM_PURPLE
@export var miss_color: Color = Color.RED
@export var success_color: Color = Color.TURQUOISE
@export var not_tight_color: Color = Color.DARK_GOLDENROD
@export var listen_icon: Texture = preload("res://stop_icon.png")
@export var play_icon: Texture = preload("res://play_icon_green.png")
@export var star_empty_icon: Texture = preload("res://Star_Empty.svg")
@export var star_filled_icon: Texture = preload("res://Star_Filled.svg")

var listen_mode_background: bool = true
var original_listen_scale: Vector2

var star_overlay_strength: float = 0.8

var stage_index: int = 0
var original_note_scale: Vector2 = Vector2(0.281,0.281)
enum note_status {IDLE,ACTIVE,PLAYED,MISSED}

var finished_round: bool = false
var notes_dictionary: Dictionary
var four_quarters_bar_duration: float = 2
var quarter_note_duration: float = 0.5  # Duration of a quarter note in seconds (120 BPM)
var elapsed_time: float = 0.0
var elapsed_time_background: float = 0.0
var beat_time: float = 0
var beat_num: int = -1
var taking_input: bool = false
var current_note_num: int = 0
var note_highlight_offset: float = 10
var sfx_player: AudioStreamPlayer
var NoteScene: PackedScene = preload("res://scenes/note.tscn")
var HitNoteScene: PackedScene = preload("res://scenes/hit_note.tscn")
var bars_passed: int = 0
var beats_passed: int = 0
var did_load_bpm_and_audio: bool = false
static var levelname: String = "dancemonkey85"
signal beat_signal
signal notes_populated_signal

static func changeToBeliver() -> void:
	levelname = "believer90"
	
static func changeToBabyShark() -> void:
	levelname = "babyShark80"
	

func load_rhythmic_pattern_level() -> void:
	notes_dictionary.clear()
	#populate_note_nodes()

	# 
	var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://levels/" + levelname + ".json")
	if not did_load_bpm_and_audio:
		tempo = rhythm_game_level.get_bpm()
		# Access the AudioStreamPlayer node
		# Load the new audio stream file
		var audio_file: String =  rhythm_game_level.get_audio_file()
		var new_stream: AudioStream = load("res://audio//" + audio_file)
		# Set the new stream to the audio player
		MusicPlayer.stream = new_stream
		did_load_bpm_and_audio = true
	
	
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
		note_nodes[i].set_type_and_duration(type, input_notes[i]["duration"])
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note in note_nodes:
		note.position.x = notes_dictionary[count]["x_location"]
		note.position.y = note_y_location
		count += 1
	#print(notes_dictionary)
	
	
	
func _ready() -> void:
	load_rhythmic_pattern_level()
	
	listen.texture = listen_icon
	original_listen_scale = listen.scale
	background.color = background_color_listen
	#populate_note_nodes()

	four_quarters_bar_duration = 60 / tempo * 4
	quarter_note_duration = 60 / tempo
	sfx_player = MusicPlayer.get_child(0)
	if not MusicPlayer.playing:
		MusicPlayer.play()
		
	elapsed_time = 0.0
	beat_time = 0 + MusicPlayer.beat_offset
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("play"):
		if taking_input:
			if current_note_num < notes_dictionary.size():
				if notes_dictionary[current_note_num]["status"] == note_status.ACTIVE:
					if note_nodes[current_note_num].type != "rest":
						pulse(current_note_num)
						sfx_player.stream = MusicPlayer.player_hit_sound
						MusicPlayer.get_child(0).volume_db = -3
						sfx_player.play()
						notes_dictionary[current_note_num]["status"] = note_status.PLAYED
						#pointer.modulate = success_color # TEMPORARY
						var current_note_location: float = notes_dictionary[current_note_num]["x_location"]
						var accuracy: float = Vector2(current_note_location, note_y_location).distance_to(Vector2(pointer.position.x, note_y_location))
						accuracy = (1 - accuracy / note_visual_offset) * 100
						var penalty: int = int(2 - accuracy / (100 / 2)) * 4
						print(accuracy)
						print(penalty)
						if penalty > 0:
							var instance: HitNote = HitNoteScene.instantiate() as HitNote
							instance.position.x = pointer.position.x
							instance.position.y = note_y_location
							add_child(instance)
							instance.current_color.r = not_tight_color.r
							instance.current_color.g = not_tight_color.g
							instance.current_color.b = not_tight_color.b
							note_nodes[current_note_num].material.set_shader_parameter("color", not_tight_color)
						else:
							#instance.current_color.r = success_color.r
							#instance.current_color.g = success_color.g
							#instance.current_color.b = success_color.b
							note_nodes[current_note_num].material.set_shader_parameter("color", success_color)
						points += points_per_note - penalty
						level_points += points_per_note - penalty
						progress_bar.value = level_points
						points_text.text = "נקודות: " + str(level_points)
						trigger_stars()
						print("yay")
						taking_input = false
					else:
						sfx_player.stream = MusicPlayer.note_sound
						MusicPlayer.get_child(0).volume_db = -3
						sfx_player.play()
						shake()
						notes_dictionary[current_note_num]["status"] = note_status.PLAYED
						note_nodes[current_note_num].material.set_shader_parameter("color", miss_color)
						points -= 10
						level_points -= 10
						progress_bar.value = level_points
						points_text.text = "נקודות: " + str(level_points)
						#pointer.modulate = miss_color
				
		else:
			#pointer.modulate = miss_color
			sfx_player.stream = MusicPlayer.note_sound
			MusicPlayer.get_child(0).volume_db = -3
			sfx_player.play()
			shake()
			#points -= points_per_note / 3
			#points_text.text = "Points: " + str(points)
			print("you suck")

func trigger_stars() -> void:
	if progress_bar.value >= progress_bar.max_value / 4:
		if star_1.texture != star_filled_icon:
			sfx_player.stream = MusicPlayer.star_success
			MusicPlayer.get_child(0).volume_db = 0
			sfx_player.play()
			star_pulse()
			star_1.texture = star_filled_icon
	if progress_bar.value >= progress_bar.max_value / 2:
		if star_2.texture != star_filled_icon:
			sfx_player.stream = MusicPlayer.star_success
			MusicPlayer.get_child(0).volume_db = 0
			sfx_player.play()
			star_pulse()
			star_2.texture = star_filled_icon
	if progress_bar.value >= progress_bar.max_value:
		if star_3.texture != star_filled_icon:
			sfx_player.stream = MusicPlayer.star_success
			MusicPlayer.get_child(0).volume_db = 0
			sfx_player.play()
			star_3.texture = star_filled_icon

func shake() -> void:
	camera_2d.rotation = 0.015
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.start()
	await timer.timeout
	camera_2d.rotation = 0


func _process(delta: float) -> void:
	change_background_color()
	#change_listen_icon()
	beat_overlay.color.a -= 0.035
	#listen.scale = lerp(original_listen_scale,original_listen_scale/1.5, quarter_note_duration / (beat_time + 0.1) / 10.0)
	elapsed_time += delta  # Accumulate time
	elapsed_time_background += delta
	beat_time += delta
	if beat_time >= quarter_note_duration:
		#print("beat")
		emit_signal("beat_signal")
		beat_num += 1
		beats_passed += 1
		print(beats_passed)
		beat_time -= quarter_note_duration 
		if beats_passed == 1:
			elapsed_time_background = 0
		if beats_passed == 3:
			listen_mode_background = !listen_mode_background
			if not listen_mode_background:
				listen.texture = play_icon
			print("changing to next background")
		elif beats_passed >= 4:
			if listen_mode_background:
				listen.texture = listen_icon
			print("BAR PASSED")
			bars_passed += 1
			beats_passed = 0
			
	#if taking_input and current_note_num < notes_dictionary.size(): # TEMPORARY
		#if notes_dictionary[current_note_num]["status"] == note_status.PLAYED:
			#pointer.modulate = success_color # TEMPORARY
	#else: # TEMPORARY
		#pointer.modulate = Color.WHITE # TEMPORARY
		
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
	pointer.modulate.a = 1
	load_rhythmic_pattern_level()
	#if instruction.text == "Listen...":
		#instruction.text = "Play!"
	#else:
		#instruction.text = "Listen..."
	points = 0
	current_note_num = 0
	notes_dictionary[0]["status"] = note_status.ACTIVE
	pointer.start_position = pointer.restart_position
	pointer.target_position = pointer.restart_target_position
	pointer.position = pointer.start_position
	
	pointer_ai.start_position = pointer_ai.restart_position
	pointer_ai.target_position = pointer_ai.restart_target_position
	pointer_ai.position = pointer_ai.start_position
	
	elapsed_time = 0

func star_pulse() -> void:
	beat_overlay.visible = true
	beat_overlay.color.a = star_overlay_strength
	
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

func change_background_color() -> void:
	if listen_mode_background:
		background.color = lerp(background.color, background_color_listen, elapsed_time_background / 30)
		#background.color = background_color_listen
		if elapsed_time_background / 30 >= 0.01:
			instruction.text = "הקשב"
	else:
		background.color = lerp(background.color, background_color_play, elapsed_time_background / 10)
		if elapsed_time_background / 30 >= 0.01:
			instruction.text = "נגן"

func change_listen_icon() -> void:
	if listen_mode_background:
		listen.texture = listen_icon
	else:
		listen.texture = play_icon
