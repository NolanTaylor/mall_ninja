extends Node2D

@onready var camera = $camera
@onready var player = $player

func _ready() -> void:
	player.wander_mode()
	
	init_interactions()
	
func _process(delta: float) -> void:
	camera.position = player.position
	
func init_interactions() -> void:
	# abstract function
	pass
