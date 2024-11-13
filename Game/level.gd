extends Node2D

@onready var player = $player

func _ready() -> void:
	for boss in $enemies.get_children():
		boss.set_player(player)
		boss.spawn_entity.connect(create_entity)
		
func create_entity(obj : Node) -> void:
	$entities.add_child(obj)
