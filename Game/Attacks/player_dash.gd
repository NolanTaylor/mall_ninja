extends "res://Game/attack.gd"

@onready var distance : int = 240
@onready var duration : float = 0.2

func activate(dir : Vector2) -> void:
	var dest : Vector2 = caster.position + dir.normalized() * distance
		
	await create_tween().tween_property(caster, "position", dest, duration).finished
	
	emit_signal("finished")
