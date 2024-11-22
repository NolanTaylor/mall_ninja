extends "res://Game/boss.gd"

@onready var sprite = $sprite

enum State {
	IDLE,
}

func _ready() -> void:
	super()
	
	run_idle()
	
func _process(delta: float) -> void:
	pass
	
func run_idle() -> void:
	if cutscene_mode:
		return
		
	state = State.IDLE
	sprite.play("idle")
	
	await get_tree().create_timer(1.0).timeout
	
	run_leap()
	
func run_combo(play_start : bool = true) -> void:
	if play_start:
		sprite.play("combo_start")
		
		await sprite.animation_finished
		
	sprite.play("combo_1")
	
	await sprite.animation_finished
	
	sprite.play("combo_2")
	
	await sprite.animation_finished
	
	sprite.play("combo_3")
	
	await sprite.animation_finished
	
	sprite.play("combo_4")
	
	await sprite.animation_finished
	
	run_idle()
	
func run_dash() -> void:
	pass
	
func run_cleave() -> void:
	pass
	
func run_leap() -> void:
	var player_pos : Vector2 = player.get_true_position()
	
	if position.x < player_pos.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	sprite.play("leap_start")
	
	await sprite.animation_finished
	
	var start : Vector2 = Vector2(position.x, position.y)
	var dest : Vector2 = Vector2.ZERO
	
	sprite.play("leap")
	
	for i in range(5):
		player_pos = player.get_true_position()
		
		if position.x < player_pos.x:
			sprite.flip_h = false
			dest = player_pos + Vector2(-80, 0)
		else:
			sprite.flip_h = true
			dest = player_pos + Vector2(80, 0)
			
		create_tween().tween_property(self, "position", lerp(start, dest, (i+1) * 0.2), 0.1)
		await get_tree().create_timer(0.1).timeout
		
	run_combo(false)
	
func run_flip() -> void:
	pass
	
func run_warp() -> void:
	pass
