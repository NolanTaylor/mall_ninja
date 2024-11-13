extends Node2D

func _ready() -> void:
	add_child(GameManager.load_dialogue(Dialogue.INTRO))
