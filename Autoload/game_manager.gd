extends Node

const SCENES : Dictionary = { # <String, String>
	"mall_floor_1": "res://Game/Hubs/Floor_1/mall_floor_1.tscn",
	"paul_fight": "res://Game/Levels/paul_fight.tscn",
}

enum GameState {
	MAIN_MENU,
	PAUSED,
	HUB,
	TALKING,
	COMBAT,
}

func load_dialogue(dialogue : Array) -> Node:
	var scene = load("res://UI/dialogue.tscn").instantiate()
	
	scene.init_scene_from_dialogue(dialogue)
	
	get_tree().root.add_child(scene)
	
	return scene
	
func go_to_scene(scene : String) -> void:
	if get_tree().change_scene_to_file(SCENES[scene]) == OK:
		pass
	else:
		get_tree().change_scene_to_file(scene)
