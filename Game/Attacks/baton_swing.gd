extends "res://Game/attack.gd"

@export var distance : Vector2 = Vector2(72, 96)

func activate(dir : Vector2) -> void:
	$collision_shape.disabled = true
	
	super(dir)
	
	position = distance * dir
	
	match dir:
		Vector2(0, -1):
			rotation_degrees = 0
		Vector2(1, -1):
			rotation_degrees = 45
		Vector2(1, 0):
			rotation_degrees = 90
		Vector2(1, 1):
			rotation_degrees = 135
		Vector2(0, 1):
			rotation_degrees = 180
		Vector2(-1, 1):
			rotation_degrees = -135
		Vector2(-1, 0):
			rotation_degrees = -90
		Vector2(-1, -1):
			rotation_degrees = -45
			
func swing() -> void:
	$collision_shape.disabled = false
