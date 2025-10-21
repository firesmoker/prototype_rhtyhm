class_name Pointer extends Sprite2D
@onready var game_manager: GameManager = $"../GameManager"

var loop_duration: float
var keep_going_loop_duration: float
#@export var time_signature: float = 4
@export var target_position: Vector2 = Vector2(1200, 209)
var keep_going_target_position: Vector2
@export var target_teacher_position: Vector2 = Vector2(2400, 209)
#@export var pointer_offset: int = 4
@export_enum("player","teacher") var type: String = "player"
@export var start_position: Vector2 = Vector2(-300, 209)
var keep_going_start_position: Vector2
@export var disappearing_pointer: bool = false
var restart_position: Vector2
#var restart_target_position: Vector2
var quarter_note_duration: float = 0.5
var player_start_position_x: float
var teacher_start_position_x: float
var notes_to_play: Array[Note]
var notes_played_count: int = 0
var sfx_player: AudioStreamPlayer = MusicPlayer.get_child(0)
var paused: bool = false
#var keep_going_mode: bool = false

func set_target_positions() -> void:
	target_position.x = game_manager.adjusted_note_quarter_gap * game_manager.time_signature
	target_teacher_position.x = target_position.x * 2

func _ready() -> void:
	set_target_positions()
	var ts: float = game_manager.time_signature
	#print("ts is " + str(ts))
	notes_to_play = game_manager.note_nodes
	player_start_position_x = game_manager.adjusted_note_quarter_gap * (- ts)
	teacher_start_position_x = 0
	if type == "player":
		var offset_modifier: float = game_manager.tempo / ts
		position.x = player_start_position_x - offset_modifier
		start_position.x = player_start_position_x - offset_modifier
		keep_going_start_position.x = 0 - offset_modifier
		
		#restart_position = Vector2(player_start_position_x - offset_modifier, start_position.y)
		#restart_target_position = Vector2(target_position.x - offset_modifier, start_position.y)
	elif type == "teacher":
		var offset_modifier: float = game_manager.tempo / ts
		position.x = teacher_start_position_x - offset_modifier
		start_position.x = teacher_start_position_x - offset_modifier
		target_position = target_teacher_position - Vector2(offset_modifier, 0)
		#restart_position = Vector2(teacher_start_position_x - offset_modifier, start_position.y)
		#restart_target_position = Vector2(target_teacher_position.x - offset_modifier, start_position.y)
		
	loop_duration = game_manager.quarter_note_duration * (ts + ts)
	keep_going_loop_duration = game_manager.quarter_note_duration * ts

func pause(toggle: bool = true) -> void:
	paused =  toggle

#func keep_going(toggle: bool) -> void:
	#keep_going_mode = toggle

func _process(_delta: float) -> void:
	if game_manager.keep_going_mode: # keep_going_loop_duration
		if type == "teacher":
			pause()
		var t: float = game_manager.elapsed_time / keep_going_loop_duration
		if not paused:
			position = Vector2(0,start_position.y).lerp(target_position, t)
	elif game_manager.elapsed_time < loop_duration:
		if type == "teacher":
			pause(false)
		var t: float = game_manager.elapsed_time / loop_duration
		if not paused:
			position = start_position.lerp(target_position, t)
	
	if notes_played_count >= 1 and disappearing_pointer:
		modulate.a -= 0.08
	
	#if type == "teacher":
	if notes_played_count < notes_to_play.size():
		if position.x >= notes_to_play[notes_played_count].position.x:
			if not MusicPlayer.playing:
				MusicPlayer.play()
			if type == "teacher":
				game_manager.pulse(notes_played_count)
				if notes_to_play[notes_played_count].type == "note":
					MusicPlayer.get_child(0).stream = MusicPlayer.teacher_note
					MusicPlayer.get_child(0).volume_db = -3
					MusicPlayer.get_child(0).play()
				else:
					MusicPlayer.get_child(0).stream = MusicPlayer.rest_sound
					MusicPlayer.get_child(0).volume_db = -3
					MusicPlayer.get_child(0).play()
				#print("sounding" + str(notes_played_count))
			notes_played_count += 1
	elif not position.x >= game_manager.note_nodes[game_manager.note_nodes.size() - 1].position.x:
		notes_played_count = 0
		print("waiting for populate signal")
		await game_manager.notes_populated_signal
		print("notes populated, updating pointer")
		notes_to_play = game_manager.note_nodes
	else:
		await game_manager.notes_populated_signal
		notes_played_count = 0
		notes_to_play = game_manager.note_nodes
