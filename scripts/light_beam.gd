extends ColorRect

var alpha_direction: float = 1

func light_pulse(time: float) -> void:
	color = Color.WHITE
	color.a = 0
	alpha_direction = 0.001
	visible = true
	#print("Light beam Timer started.")
	await get_tree().create_timer(time).timeout
	color = Color.WHITE
	color.a = 1
	alpha_direction = -0.025
	#visible = false

func _ready() -> void:
	color.a = 0
	alpha_direction = 0

func _process(delta: float) -> void:
	color.a += alpha_direction
	if color.a > 1:
		color.a = 1
	elif color.a < 0:
		color.a = 0
