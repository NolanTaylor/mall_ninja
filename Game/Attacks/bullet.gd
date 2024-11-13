extends "res://Game/attack.gd"

const SPEED : int = 480

var velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	position += velocity * delta
	
func activate(dir : Vector2) -> void:
	super(dir)
	
	velocity = SPEED * dir
