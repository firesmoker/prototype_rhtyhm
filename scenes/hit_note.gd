class_name HitNote extends Sprite2D

@export var original_color: Color
@export var fade_speed: float = 0.03
var current_color: Color


func _ready() -> void:
	current_color = original_color
	material.set_shader_parameter("color",original_color)
	material.set_shader_parameter("alpha",original_color.a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_color.a -= fade_speed
	material.set_shader_parameter("color",current_color)
	material.set_shader_parameter("alpha",current_color.a)
	if current_color.a <= 0:
		queue_free()
