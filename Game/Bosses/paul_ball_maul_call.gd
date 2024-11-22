extends "res://Game/boss.gd"

@onready var bullet : PackedScene = preload("res://Game/Attacks/bullet.tscn")

enum State {
	IDLE,
	CHARGE,
	SHOOT,
	BATON,
}

enum Wheels {
	BIG,
	NORMAL,
	BRAKE,
}

var moving_baton : bool = false

signal reached_player

func _ready() -> void:
	super()
	
	run_idle()
	
func _process(delta: float) -> void:
	if cutscene_mode:
		return
		
	if moving_baton:
		global_position = position.move_toward(player.get_true_position(), 400 * delta)
		if position.distance_to(player.get_true_position()) < 72:
			moving_baton = false
			emit_signal("reached_player")
			
func run_idle() -> void:
	if cutscene_mode:
		return
		
	state = State.IDLE
	velocity = Vector2.ZERO
	$sprite.play("idle")
	
	await get_tree().create_timer(1.0).timeout
	
	match randi_range(0, 2):
		0:
			run_charge()
		1:
			run_shoot()
		2:
			run_baton()
		_:
			run_idle()
			
func run_charge() -> void:
	state = State.CHARGE
	
	for i in range(2):
		for dir in Globals.DIRECTIONS:
			run_to(global_position + dir * 48, Wheels.NORMAL)
			velocity = dir * speed
			await get_tree().create_timer(0.08).timeout
			
	var dir = Globals.get_direction_analog(player.get_true_position(), global_position)
	velocity = -dir * speed * 0.5
	run_to(global_position + dir * 48, Wheels.BIG)
	
	await get_tree().create_timer(0.8).timeout
	
	velocity = dir * speed * 2.0
	run_to(global_position + dir * 48, Wheels.NORMAL)
	
	await get_tree().create_timer(1.4).timeout
	
	velocity = dir * speed * 0.5
	run_to(global_position + dir * 48, Wheels.BRAKE)
	
	await get_tree().create_timer(0.8).timeout
	
	run_idle()
	
func run_shoot() -> void:
	state = State.SHOOT
	
	$sprite.play("pull_gun")
	
	await $sprite.animation_finished
	
	for i in range(3):
		var new_bullet = bullet.instantiate()
		var dir_to_player = Globals.get_direction_analog(player.get_true_position(), global_position)
		
		if dir_to_player.x < 0:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
			
		$sprite.play("fire")
		emit_signal("spawn_entity", new_bullet)
		
		new_bullet.set_caster(self)
		new_bullet.position = position
		new_bullet.activate(dir_to_player)
		
		await get_tree().create_timer(0.4).timeout
		
	run_idle()
	
func run_baton() -> void:
	state = State.BATON
	
	$sprite.play("pull_baton")
	
	await $sprite.animation_finished
	
	moving_baton = true
	
	await self.reached_player
	
	var dir_to_player = Globals.get_direction_snap(player.get_true_position(), global_position)
	
	$baton.activate(dir_to_player)
	await get_tree().create_timer(0.2).timeout
	$sprite.play("swing")
	$baton.swing()
	await $sprite.animation_finished
	$baton.cancel()
	
	run_idle()
	
func run_to(pos : Vector2, wheels : int = Wheels.NORMAL) -> void:
	var dir = Globals.get_direction_snap(pos, global_position)
	
	if dir.x < 0:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false
		
	var mod : String = ""
	
	match wheels:
		Wheels.BIG:
			mod = "big_"
		Wheels.BRAKE:
			mod = "brake_"
			
	match dir:
		Vector2(0, -1):
			$sprite.play("run_{0}n".format([mod]))
		Vector2(1, -1), Vector2(-1, -1):
			$sprite.play("run_{0}ne".format([mod]))
		Vector2(1, 0), Vector2(-1, 0):
			$sprite.play("run_{0}e".format([mod]))
		Vector2(1, 1), Vector2(-1, 1):
			$sprite.play("run_{0}se".format([mod]))
		Vector2(0, 1):
			$sprite.play("run_{0}s".format([mod]))
			
func _on_collision(collider : KinematicCollision2D) -> void:
	pass
