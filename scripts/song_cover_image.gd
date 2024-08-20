extends Sprite2D

@onready var beliver: Node2D = $"../../Beliver/cover_image"
@onready var BabyShark: Node2D = $"../../BabyShark/cover_image"
@onready var level1: Node2D = $"../../Level1/cover_image"
@onready var level2: Node2D = $"../../Level2/cover_image"
@onready var level3: Node2D = $"../../Level3/cover_image"
@onready var level4: Node2D = $"../../Level4/cover_image"
@onready var level5: Node2D = $"../../Level5/cover_image"
@onready var level6: Node2D = $"../../Level6/cover_image"
@onready var level7: Node2D = $"../../Level7/cover_image"


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.changeToBeliver()
		var new_scene: PackedScene = preload("res://scenes/game.tscn")
		# Change to the preloaded scene
		var scene_instance: Node = new_scene.instantiate()
		var specific_node: Node = scene_instance.get_node("GameManager")
		if beliver.get_rect().has_point(beliver.to_local(event.position)):
			specific_node.levelname = "believer90"
			get_tree().change_scene_to_packed(new_scene)

		if BabyShark.get_rect().has_point(BabyShark.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level1.get_rect().has_point(level1.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level2.get_rect().has_point(level2.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level3.get_rect().has_point(level3.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level4.get_rect().has_point(level4.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level5.get_rect().has_point(level5.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level6.get_rect().has_point(level6.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)
			
		if level7.get_rect().has_point(level7.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark80"
			get_tree().change_scene_to_packed(new_scene)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
