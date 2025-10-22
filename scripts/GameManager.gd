class_name GameManager extends Node

@onready var points_text: Label = $"../HUD/PointsText"
@onready var instruction: Label = $"../Background/Instruction"
@onready var notes_container: Node2D = $"../Notes"
@onready var background: ColorRect = $"../Background/ColorRect"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var progress_bar: ProgressBar = $"../HUD/ProgressBar"
@onready var star_success_overlay: ColorRect = $"../Background/StarSuccessOverlay"
@onready var vignette: TextureRect = $"../Background/ColorRect/Vignette"
@onready var audio: AudioStreamPlayer = $"../Audio1"
@onready var audio2: AudioStreamPlayer = $"../Audio2"
@onready var debug_current_note_num: Label = $"../HUD/DebugCurrentNoteNum"
@onready var delayed_hit_timer: Timer = $"../DelayedHitTimer"
@onready var light_beams: Control = $"../LightBeams"

@onready var listen: Sprite2D = $"../Listen"

@onready var pointer: Pointer = $"../Pointer"
@onready var pointer_ai: Pointer = $"../Pointer_AI"
@onready var star_1: Sprite2D = $"../HUD/Star1"
@onready var star_2: Sprite2D = $"../HUD/Star2"
@onready var star_3: Sprite2D = $"../HUD/Star3"


@export var note_nodes: Array[Note]
@export var note_y_location: float = -52
@export var note_quarter_gap: float = 300
var adjusted_note_quarter_gap: float
@export var note_visual_offset: float = 100
@export var tempo: float = 120 # in BPM
#@export var points: int = 0
@export var level_points: int = 0
@export var points_per_note: int = 10

@export var background_color_listen: Color = Color.DARK_SLATE_BLUE
@export var background_color_play: Color = Color.MEDIUM_PURPLE
@export var miss_color: Color = Color.RED
@export var success_color: Color = Color.TURQUOISE
@export var not_tight_color: Color = Color.DARK_GOLDENROD
@export var listen_icon: Texture = preload("uid://d4egegdc4orhv")
@export var play_icon: Texture = preload("uid://bmy3pf53wlaxs")
@export var star_empty_icon: Texture = preload("uid://v3cxc6ouqia7")
@export var star_filled_icon: Texture = preload("uid://bnogovfwbmyjp")

var delayed_hit_viable: bool = false
var current_rhythm_game_level: RhythmGameLevel
var change_to_listen_ui: bool = true
var original_listen_scale: Vector2
@export var beat_visuals_on: bool = false
var star_overlay_strength: float = 0.8
var game_status: int
enum game_status_types {LISTEN,PLAY}
var next_stage_status: String
var ready_to_start_keep_going: bool = false
var keep_going_repeats: int = 0
var keep_going_repeats_passed: int = 0
var time_signature: float = 4
var stage_index: int = 0
var original_note_scale: Vector2 = Vector2(0.281,0.281)
enum note_status {IDLE,ACTIVE,PLAYED,MISSED}

var playing_delayed_hit: bool = false
var loop_finished: bool = false
var notes_dictionary: Dictionary
var four_quarters_bar_duration: float = 2
var quarter_note_duration: float = 0.5  # Duration of a quarter note in seconds (120 BPM)
var elapsed_time: float = 0.0
var elapsed_background_time: float = 0.0
var beat_time: float = 0
var pre_beat_time: float = 0
@export var pre_beat_modifier: float = 0.3
#var beat_num: int = -1
var taking_input: bool = false
var current_note_num: int = 0
var note_highlight_offset: float = 10
var NoteScene: PackedScene = preload("res://scenes/note.tscn")
var HitNoteScene: PackedScene = preload("res://scenes/hit_note.tscn")
var beats_passed: int = 0
var pre_beats_passed: int = 0
var did_load_bpm_and_audio: bool = false
var keep_going_mode: bool = false
var dual_pointer_mode: bool = false
var current_active_pointer: Pointer
static var levelname: String = "dancemonkey85"
signal beat_signal
signal notes_populated_signal
signal restart_signal

static func changeToLevel(level_name: String) -> void:
	levelname = level_name

func set_ui() -> void:
	listen.texture = listen_icon
	original_listen_scale = listen.scale
	background.color = background_color_listen

func set_light_beams() -> void:
	var count: int = 0
	for light_beam: ColorRect in light_beams.get_children():
		light_beam.visible = false
		light_beam.position.x = adjusted_note_quarter_gap * count - light_beam.size.x / 2
		count += 1

func _ready() -> void:
	load_rhythmic_pattern_level()
	set_light_beams()
		
	#for i: int in time_signature:
		
	set_ui()
	#print("setting durations with time signature " + str(time_signature))
	four_quarters_bar_duration = 60 / tempo * time_signature
	quarter_note_duration = 60 / tempo
	elapsed_time = 0.0
	beat_time = 0 + MusicPlayer.beat_offset
	light_beams.get_child(0).light_pulse(pre_beat_modifier)

func _process(delta: float) -> void:
	vignette.self_modulate.a -= 0.025
	if not MusicPlayer.playing:
		MusicPlayer.play()
	change_game_status_visuals()
	elapsed_time += delta
	elapsed_background_time += delta
	beat_time += delta
	pre_beat_time += delta
	if pre_beat_time >= quarter_note_duration - pre_beat_modifier:
		pre_beats_passed += 1
		#beat_light_pulse(pre_beats_passed)
		#print(pre_beats_passed)
		pre_beat_time -= quarter_note_duration
		if pre_beats_passed >= time_signature:
			print("prebeat 0")
			pre_beats_passed = 0
		beat_light_pulse(pre_beats_passed)
	if beat_time >= quarter_note_duration:
		#beat_num += 1
		beats_passed += 1
		beat_time -= quarter_note_duration
		#emit_signal("beat_signal",beats_passed) # go to beat_effects
		if beats_passed >= time_signature:
			beats_passed = 0
		emit_signal("beat_signal",beats_passed)
	bar_loop()

func beat_effects(beat_num: int) -> void:
	#beat_light_pulse(beat_num)
	if beat_visuals_on:
		vignette.self_modulate.a = 0.5
	if keep_going_mode:
		change_to_listen_ui = false
	if beat_num == 1:
		elapsed_background_time = 0
	if beat_num == 3:
		if not keep_going_mode:
			change_to_listen_ui = !change_to_listen_ui
		if not change_to_listen_ui:
			listen.texture = play_icon
		if change_to_listen_ui and not ready_to_start_keep_going:
			print("LISTEN")
			listen.texture = listen_icon
	elif beat_num >= time_signature or beat_num == 0:
		#if ready_to_start_keep_going:
			#keep_going_mode = true
		if change_to_listen_ui and not ready_to_start_keep_going:
			print("LISTEN")
			listen.texture = listen_icon
		#beats_passed = 0

func change_active_note() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	handle_input_wip(event)
	if event.is_action_pressed("pause"):
		pointer_ai.pause(!pointer_ai.paused)

func handle_input_wip(event: InputEvent) -> void:
	if taking_input:
		if event.is_action_pressed("play"):
			play_note()
	else:
		pass
					
func delayed_hit() -> void:
	if not playing_delayed_hit:
		delayed_hit_timer.start(0.1)
		print("delayed hit started")
		playing_delayed_hit = true
		delayed_hit_viable = true
		await restart_signal
		if delayed_hit_viable:
			delayed_hit_timer.stop()
			play_note()
		playing_delayed_hit = false
		print("delayed hit happened")
	else:
		print("delayed hit rejected")

func play_note() -> void:
	if current_note_num < notes_dictionary.size():
		if notes_dictionary[current_note_num]["status"] == note_status.ACTIVE:
			if note_nodes[current_note_num].type != "rest":
				notes_dictionary[current_note_num]["status"] = note_status.PLAYED
			else:
				notes_dictionary[current_note_num]["status"] = note_status.MISSED
			note_hit_effect(current_note_num)
			calculate_note_hit_success()
		elif current_note_num == notes_dictionary.size()-1:
			print("triggered delayed hit")
			delayed_hit()
	elif current_note_num >= notes_dictionary.size():
		print("triggered delay hit")
		delayed_hit()

func note_hit_effect(note_num: int) -> void:
	pulse(note_num)
	audio.stream = MusicPlayer.player_hit_sound
	MusicPlayer.get_child(0).volume_db = -3
	audio.play()

func calculate_note_hit_success() -> void:
	if note_nodes[current_note_num].type != "rest":
		var current_note_location: float = notes_dictionary[current_note_num]["x_location"]
		var accuracy: float = Vector2(current_note_location, note_y_location).distance_to(Vector2(pointer.position.x, note_y_location))
		accuracy = (1 - accuracy / note_visual_offset) * 100
		var penalty: int = int(2 - accuracy / (100 / 2)) * 4
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
			note_nodes[current_note_num].material.set_shader_parameter("color", success_color)
		add_points(points_per_note - penalty)
		#taking_input = false
	else:
		shake()
		note_nodes[current_note_num].material.set_shader_parameter("color", miss_color)

func enable_keep_going(number_of_repeats: int = 2) -> void:
	keep_going_repeats = number_of_repeats
	keep_going_repeats_passed = 0
	#keep_going_mode = true
	ready_to_start_keep_going = true

func set_bar_stage(rhythm_game_level: RhythmGameLevel) -> void:
	#print(notes_dictionary.size())
	stage_index = (stage_index % rhythm_game_level.get_stages_number()) + 1
	print("load new rhythmic pattern for stage ", stage_index)
	var stage: Dictionary = rhythm_game_level.get_stage(stage_index)
	# Assuming stages["notes"] contains the list of notes
	var input_notes: Array[Dictionary] = []
	if "keepGoing" in stage:
		enable_keep_going(stage["keepGoing"])
	if "notes" in stage:
		for note: Dictionary in stage["notes"]:
			input_notes.append(note)
	
	populate_note_nodes(input_notes.size())
			
	for i: int in range(input_notes.size()):
		var type: String  = "note"
		if input_notes[i]["is_rest"]:
			type = "rest"
		if i == 0:
			notes_dictionary[i] = {
				"x_location": 0,
				"duration": input_notes[i]["duration"],
				"type": type,
				"status": note_status.IDLE,
		}
		else:
			notes_dictionary[i] = {
				"x_location": notes_dictionary[i-1]["x_location"] + adjusted_note_quarter_gap * input_notes[i-1]["duration"],
				"duration": input_notes[i]["duration"],
				"type": type,
				"status": note_status.IDLE,
			}
		print("duration for note is: " + str(input_notes[i]["duration"]))
		note_nodes[i].set_type_and_duration(type, input_notes[i]["duration"])
	
	notes_dictionary[0]["status"] = note_status.ACTIVE
	
	var count: int = 0
	for note: Note in note_nodes:
		note.position.x = notes_dictionary[count]["x_location"]
		note.position.y = note_y_location
		count += 1

func load_rhythmic_pattern_level() -> void:
	#print("load rhythmic apttern level func")
	notes_dictionary.clear()

	# 
	var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://levels/" + levelname + ".json")
	current_rhythm_game_level = rhythm_game_level
	time_signature = rhythm_game_level.get_time_signature()
	#print(time_signature)
	if not did_load_bpm_and_audio:
		tempo = rhythm_game_level.get_bpm()
		var audio_file: String =  rhythm_game_level.get_audio_file()
		var new_stream: AudioStream = load("res://music//" + audio_file)
		MusicPlayer.stream = new_stream
		did_load_bpm_and_audio = true
		adjusted_note_quarter_gap = note_quarter_gap * 4 / time_signature
	set_bar_stage(current_rhythm_game_level)


func trigger_stars() -> void:
	if progress_bar.value >= progress_bar.max_value / 4:
		if star_1.texture != star_filled_icon:
			audio2.stream = MusicPlayer.star_success
			audio2.play()
			star_pulse()
			star_1.texture = star_filled_icon
	if progress_bar.value >= progress_bar.max_value / 2:
		if star_2.texture != star_filled_icon:
			audio2.stream = MusicPlayer.star_success
			audio2.play()
			star_pulse()
			star_2.texture = star_filled_icon
	if progress_bar.value >= progress_bar.max_value:
		if star_3.texture != star_filled_icon:
			audio2.stream = MusicPlayer.star_success
			audio2.play()
			star_3.texture = star_filled_icon

func shake() -> void:
	camera_2d.rotation = 0.005
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.start()
	await timer.timeout
	camera_2d.rotation = 0

func add_points(new_points: int) -> void:
	#points += new_points
	level_points += new_points
	progress_bar.value = level_points
	points_text.text = "נקודות: " + str(level_points)
	trigger_stars()

func pointer_at_current_note(current_note_x_position: float, offset: float) -> bool:
	if not pointer.position.x >= current_note_x_position - offset:
		return false
	if not pointer.position.x <= current_note_x_position + offset:
		return false
	if not notes_dictionary[current_note_num]["status"] != note_status.PLAYED:
		return false
	return true

func bar_loop() -> void:
	#var current_bar_stage_index: int = stage_index
	if current_note_num < note_nodes.size():
		#print(current_note_num)
		#print(notes_dictionary.size())
		var offset: float = note_visual_offset * notes_dictionary[current_note_num]["duration"]
		var current_note_x_position: float = notes_dictionary[current_note_num]["x_location"]
		if pointer_at_current_note(current_note_x_position, offset):
			taking_input = true
		elif pointer.position.x >= current_note_x_position + offset: #if pointer passed current note
			if notes_dictionary[current_note_num]["status"] != note_status.PLAYED:
				if notes_dictionary[current_note_num]["type"] != "rest":
					note_nodes[current_note_num].material.set_shader_parameter("color", miss_color)
				elif notes_dictionary[current_note_num]["status"] != note_status.MISSED:
					add_points(points_per_note)
			current_note_num += 1
			debug_current_note_num.text = "current_note_num: " + str(current_note_num)
			if current_note_num < notes_dictionary.size():
				notes_dictionary[current_note_num]["status"] = note_status.ACTIVE
	else:
		print("bar notes ended")
		if not keep_going_mode:
			taking_input = false
		if not loop_finished:
			loop_finished = true
		await beat_signal
		if loop_finished:
			print("RESTART!")
			if ready_to_start_keep_going:
				keep_going_mode = true
				ready_to_start_keep_going = false
			restart_level()
			loop_finished = false


func clear_notes_colors() -> void:
	for note: Note in note_nodes:
		note.material.set_shader_parameter("color", Color.BLACK)

func pulse(note_num: int) -> void:
	if note_num >= note_nodes.size():
		return
	note_nodes[note_num].scale = original_note_scale * 1.25
	note_nodes[note_num].position.y -= note_highlight_offset
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.start()
	await timer.timeout
	if note_num >= note_nodes.size():
		return
	note_nodes[note_num].scale = original_note_scale
	note_nodes[note_num].position.y += note_highlight_offset
	
func beat_light_pulse(note_num: int) -> void:
	var beams: Array = light_beams.get_children()
	#beams[note_num].visible = true
	beams[note_num].light_pulse(pre_beat_modifier)
	

func restart_level() -> void:
	print("restart level func")
	pointer.modulate.a = 1
	if keep_going_mode:
		clear_notes_colors()
		keep_going_repeats_passed += 1
		if keep_going_repeats_passed >= keep_going_repeats:
			keep_going_repeats_passed = 0
			keep_going_mode = false
			change_to_listen_ui = true
	if not keep_going_mode:
		set_bar_stage(current_rhythm_game_level)
		
	current_note_num = 0
	debug_current_note_num.text = "current_note_num: " + str(current_note_num)
	notes_dictionary[0]["status"] = note_status.ACTIVE
	#points = 0
	#pointer.start_position = pointer.restart_position
	#pointer.target_position = pointer.restart_target_position
	pointer.position = pointer.start_position
	
	#pointer_ai.start_position = pointer_ai.restart_position
	#pointer_ai.target_position = pointer_ai.restart_target_position
	pointer_ai.position = pointer_ai.start_position
	
	elapsed_time = 0
	change_game_status()
	emit_signal("restart_signal")

func star_pulse() -> void:
	star_success_overlay.visible = true
	star_success_overlay.color.a = star_overlay_strength
	
func populate_note_nodes(number_of_notes: int = time_signature) -> void:
	note_nodes.clear()
	for n: Node in notes_container.get_children():
		notes_container.remove_child(n)
		n.queue_free()
		
	for i: int in range(number_of_notes):
		var instance: Note = NoteScene.instantiate() as Note
		notes_container.add_child(instance)
		note_nodes.append(instance)
	emit_signal("notes_populated_signal")

func change_game_status() -> void:
	match game_status:
		game_status_types.LISTEN:
			game_status = game_status_types.PLAY
		game_status_types.PLAY:
			if keep_going_mode:
				if keep_going_repeats_passed >= keep_going_repeats:
					game_status = game_status_types.PLAY
				else:
					return
			else:
				game_status = game_status_types.LISTEN
		
	

func change_game_status_visuals() -> void:
	star_success_overlay.color.a -= 0.035
	if keep_going_mode:
		background.color = lerp(background.color, background_color_play, elapsed_background_time / 10)
		instruction.text = "תמשיך לנגן"
		return
	if change_to_listen_ui and not ready_to_start_keep_going:
		background.color = lerp(background.color, background_color_listen, elapsed_background_time / 30)
		if elapsed_background_time / 30 >= 0.01:
			instruction.text = "הקשב"
	else:
		background.color = lerp(background.color, background_color_play, elapsed_background_time / 10)
		if elapsed_background_time / 30 >= 0.01:
			instruction.text = "נגן"

#func change_listen_icon() -> void:
	#if keep_going_mode:
		#listen.texture = play_icon
		#return
	#if change_to_listen_ui:
		#listen.texture = listen_icon
	#else:
		#listen.texture = play_icon


func _on_delayed_hit_timer_timeout() -> void:
	delayed_hit_viable = false
	print("delayed hit too long and disabled")
