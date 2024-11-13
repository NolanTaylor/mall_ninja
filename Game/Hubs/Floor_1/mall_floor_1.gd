extends "res://Game/hub.gd"

func _ready() -> void:
	super()
	
	$fountain.play("default")
	
func init_interactions() -> void:
	$interactions/cinnabon_door.interacted.connect(func (): GameManager.load_dialogue(Dialogue.INTRO))
