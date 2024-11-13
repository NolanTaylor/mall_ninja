extends Node2D

func tween(object : Object, property : NodePath, final : Variant, duration : float) -> Signal:
	return create_tween().tween_property(object, property, final, duration).finished
	
func wait(time : float) -> Signal:
	return get_tree().create_timer(time).timeout
	
func play_dialogue(dialogue : Array) -> Signal:
	return GameManager.load_dialogue(dialogue).finished
