extends Sprite2D

@onready var beliver: Node2D = $"../../Beliver/cover_image"
@onready var BabyShark: Node2D = $"../../BabyShark/cover_image"
@onready var BabySharkHarder: Node2D = $"../../BabySharkHarder/cover_image"
@onready var DanceMonkey: Node2D = $"../../DanceMonkey/cover_image"
@onready var DanceMonkeyHarder: Node2D = $"../../DanceMonkeyHarder/cover_image"
@onready var CountingStars: Node2D = $"../../CountingStars/cover_image"
@onready var BelieverHarder: Node2D = $"../../BelieverHarder/cover_image"
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
			
		if BabySharkHarder.get_rect().has_point(BabySharkHarder.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "babyShark110"
			get_tree().change_scene_to_packed(new_scene)
			
		if DanceMonkey.get_rect().has_point(DanceMonkey.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "dancemonkey85"
			get_tree().change_scene_to_packed(new_scene)
			
		if DanceMonkeyHarder.get_rect().has_point(DanceMonkeyHarder.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "dancemonkey90"
			get_tree().change_scene_to_packed(new_scene)
			
		if CountingStars.get_rect().has_point(CountingStars.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "countingStars122"
			get_tree().change_scene_to_packed(new_scene)
			
		if BelieverHarder.get_rect().has_point(BelieverHarder.to_local(event.position)):
			GameManager.changeToBabyShark()
			specific_node.levelname = "believer115"
			get_tree().change_scene_to_packed(new_scene)
			
		if level6.get_rect().has_point(level6.to_local(event.position)):
			GameManager.changeToPantera()
			specific_node.levelname = "Pantera"
			get_tree().change_scene_to_packed(new_scene)
			
		if level7.get_rect().has_point(level7.to_local(event.position)):
			GameManager.changeToHappy()
			specific_node.levelname = "happy160"
			get_tree().change_scene_to_packed(new_scene)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
