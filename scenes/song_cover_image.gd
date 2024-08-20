extends Sprite2D

@onready var beliver: Node2D = $"../../Beliver/cover_image"
@onready var BabyShark: Node2D = $"../../BabyShark/cover_image"
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if beliver.get_rect().has_point(beliver.to_local(event.position)):
			# Change scene by providing the path to the new scene file
			# Preload the scene
			GameManager.changeToBeliver()
			var new_scene: PackedScene = preload("res://scenes/game.tscn")
			#var newSceneInt: Node = new_scene.instantiate()
			# Change to the preloaded scene
			
			var scene_instance: Node = new_scene.instantiate()
			var specific_node: Node = scene_instance.get_node("GameManager")
			specific_node.levelname = "believer90"
			
			get_tree().change_scene_to_packed(new_scene)
			
			
			
		if BabyShark.get_rect().has_point(BabyShark.to_local(event.position)):
			# Change scene by providing the path to the new scene file
			# Preload the scene
			GameManager.changeToBabyShark()
			var new_scene: PackedScene = preload("res://scenes/game.tscn")
			var scene_instance: Node = new_scene.instantiate()
			var specific_node: Node = scene_instance.get_node("GameManager")
			# Change to the preloaded scene
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
