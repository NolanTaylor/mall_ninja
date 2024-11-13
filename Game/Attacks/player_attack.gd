extends "res://Game/attack.gd"

@export var distance : Vector2 = Vector2(64, 80)

func activate(dir : Vector2) -> void:
	super(dir)
	
	position = distance * dir
	
	if dir.x > 0:
		set_flip_h(true)
	else:
		set_flip_h(false)
		
	match dir:
		Vector2(-1, 0), Vector2(1, 0):
			rotation_degrees = 0
		Vector2(-1, -1), Vector2(1, 1):
			rotation_degrees = 45
		Vector2(-1, 1), Vector2(1, -1):
			rotation_degrees = -45
		Vector2(0, -1):
			rotation_degrees = 90
		Vector2(0, 1):
			rotation_degrees = -90
			
	$sprite.play("swing")
