extends "res://Game/attack.gd"

const OFFSET : Vector2 = Vector2(0, -60)

@export var distance : Vector2 = Vector2(64, 80)

func activate(dir : Vector2) -> void:
	super(dir)
	
	position = distance * dir + OFFSET
	
	if dir.x > 0:
		set_flip_h(true)
	else:
		set_flip_h(false)
		
	rotation = atan2(dir.y, dir.x) + PI / 2
	
	$sprite.play("swing")
