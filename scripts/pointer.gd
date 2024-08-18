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
var notes_to_play: Array[Note]
var notes_played_count: int = 0
var sfx_player: AudioStreamPlayer = MusicPlayer.get_child(0)

func _ready() -> void:
	notes_to_play = game_manager.note_nodes
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
		
	duration = game_manager.quarter_note_duration * (beat_duration + pointer_offset)

func _process(delta: float) -> void:
	if game_manager.elapsed_time < duration:
		var t: float = game_manager.elapsed_time / duration
		position = start_position.lerp(target_position, t)
	
	#if type == "teacher":
	if notes_played_count < notes_to_play.size():
		if position.x >= notes_to_play[notes_played_count].position.x:
			game_manager.pulse(notes_played_count)
			if not MusicPlayer.playing:
				MusicPlayer.play()
			if type == "teacher":
				if notes_to_play[notes_played_count].type == "note":
					MusicPlayer.get_child(0).stream = MusicPlayer.player_hit_sound
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
