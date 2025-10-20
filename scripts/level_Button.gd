extends TextureButton

@export var level_name: String
@export var song_name: String
@onready var label: Label = $Label

func _ready() -> void:
	if song_name:
		label.text = song_name
	else:
		label.text = level_name

func _on_button_down() -> void:
	var new_scene: PackedScene = preload("res://scenes/game.tscn")
	var scene_instance: Node = new_scene.instantiate()
	var specific_node: Node = scene_instance.get_node("GameManager")
	GameManager.changeToLevel(level_name)
	specific_node.levelname = level_name
	get_tree().change_scene_to_packed(new_scene)	
