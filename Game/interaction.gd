extends Area2D

@onready var interact_prompt = $interact_prompt

var present : bool = false

signal interacted

func _ready() -> void:
	interact_prompt.hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and present:
		emit_signal("interacted")
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		present = true
		interact_prompt.show()
		interact_prompt.frame = 0
		interact_prompt.play("prompt")
		await interact_prompt.animation_finished
		interact_prompt.play("default")
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		present = false
		interact_prompt.hide()
