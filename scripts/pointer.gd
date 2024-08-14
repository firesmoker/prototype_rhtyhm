extends Sprite2D
@onready var game_manager: GameManager = $"../GameManager"
var duration: float = 2.5
@export var beat_duration: float = 4
@export var target_position: Vector2 = Vector2(1200, 209)
@export var target_teacher_position: Vector2 = Vector2(2400, 209)
@export var pointer_offset: int = 4
@export_enum("player","teacher") var type: String = "player"
@export var start_position: Vector2 = Vector2(-300, 209)
var restart_position: Vector2
var restart_target_position: Vector2
var quarter_note_duration: float = 0.5
var original_beat_duration: float = 4
var original_duration: float
var player_start_position_x: float
var teacher_start_position_x: float
var notes_to_play: Array[Node2D]
var notes_played_count: int = 0

func _ready() -> void:
	#original_beat_duration = beat_duration
	notes_to_play = game_manager.notes
	player_start_position_x = game_manager.note_quarter_gap * (4 - beat_duration - pointer_offset)
	teacher_start_position_x = game_manager.note_quarter_gap * (beat_duration - pointer_offset)
	if type == "player":
		position.x = player_start_position_x
		start_position.x = player_start_position_x
		restart_position = Vector2(player_start_position_x, start_position.y)
		restart_target_position = Vector2(target_position.x, start_position.y)
	elif type == "teacher":
		position.x = teacher_start_position_x
		start_position.x = teacher_start_position_x
		target_position = target_teacher_position
		restart_position = Vector2(teacher_start_position_x, start_position.y)
		restart_target_position = Vector2(target_teacher_position.x, start_position.y)
		#beat_duration = beat_duration / 2
		
	duration = game_manager.quarter_note_duration * (beat_duration + pointer_offset)
	#original_duration = duration
	#if type == "teacher":
		#duration = duration / 2
	#start_position = position
	#restart_position = Vector2(start_position.x - game_manager.note_visual_offset / 2, start_position.y)
	#restart_target_position = Vector2(target_position.x - game_manager.note_visual_offset / 2, target_position.y)

func _process(delta: float) -> void:
	if game_manager.elapsed_time < duration:
		# Calculate the interpolation factor (0.0 to 1.0)
		var t: float = game_manager.elapsed_time / duration
		# Interpolate position linearly from start to target
		position = start_position.lerp(target_position, t)
	
	if type == "teacher":
		if notes_played_count < notes_to_play.size():
			if position.x >= notes_to_play[notes_played_count].position.x:
				if notes_to_play[notes_played_count].type == "note":
					MusicPlayer.get_child(0).play()
				print("sounding" + str(notes_played_count))
				#notes_to_play.pop_front()
				notes_played_count += 1
				#print("SOUND!")
		elif not position.x >= game_manager.notes[game_manager.notes.size() - 1].position.x:
			notes_played_count = 0
			notes_to_play = game_manager.notes
		
	#elif type == "teacher":
		#start_position.x = player_start_position_x
		#beat_duration = original_beat_duration
		#duration = original_duration
	#else:
	#else:
	#else:
		## Ensure the final position is exactly the target position
		#position = target_position
		#print("Movement completed!")
		##set_process(false)  # Stop processing if you don't need to continue after the movement is done
