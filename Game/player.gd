extends CharacterBody2D

const HAT_ICON : PackedScene = preload("res://UI/hat_ui.tscn")
const MAX_SPEED : int = 300
const MAX_LAG : float = 0.4
const PARRY_WINDOW : float = 0.08
const IFRAMES : float = 0.35
const CHARGE_TIME : float = 0.35

@export var cutscene_mode : bool = false

@onready var health_container = $canvas_layer/health_container
@onready var hitbox = $hit_box
@onready var collision_box = $collision_box
@onready var sprite = $sprite
@onready var charge_aura = $charge_aura_sprite
@onready var parry_effect = $parry_effect

const RUN_ANIMATIONS : Array = [ # <String>
	"run_n",
	"run_ne",
	"run_e",
	"run_se",
	"run_s",
	"run_sw",
	"run_w",
	"run_nw",
]

const TRANS_ANIMATIONS : Array = [ # <String>
	"trans_n",
	"trans_ne",
	"trans_e",
	"trans_se",
	"trans_s",
	"trans_sw",
	"trans_w",
	"trans_nw",
]

enum State {
	NEUTRAL,
	ATTACKING,
	CHARGING,
	DASHING,
	PARRYING,
	STUNNED,
	CUTSCENE,
}

var state : int = State.NEUTRAL
var direction : Vector2 = Vector2.ZERO

var health : int = 5

var charge_count : float = 0.0
var parry_count : float = 0.0
var post_hit_count : float = 0.0
var iframe_count : float = 0.0
var attack_lag : float = 0.0
var attack_count : int = 0
var attack_buffer : String = ""
var parry_buffer : String = ""

signal player_death

func _ready() -> void:
	add_to_group("Player")
	
	for child in $attacks.get_children():
		child.set_caster(self)
		
	for i in range(health):
		health_container.add_child(HAT_ICON.instantiate())
		
	if cutscene_mode:
		state = State.CUTSCENE
		
func _process(delta: float) -> void:
	if iframe_count > 0.0:
		iframe_count -= delta
		
	match state:
		State.NEUTRAL:
			run_neutral(delta)
		State.ATTACKING:
			run_attacking(delta)
		State.CHARGING:
			run_charging(delta)
		State.PARRYING:
			run_parrying(delta)
		_:
			pass
			
func _physics_process(delta: float) -> void:
	if state == State.DASHING:
		pass
	elif direction == Vector2.ZERO or state != State.NEUTRAL:
		velocity = lerp(velocity, Vector2.ZERO, 0.2)
	else:
		velocity = lerp(velocity, MAX_SPEED * direction, 0.15)
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("left") and event.is_action_released("right") and \
	event.is_action_released("up") and event.is_action_released("down"):
		direction = Vector2.ZERO
		
	if event.is_action_released("left"):
		direction.x = 0
		if Input.is_action_pressed("right"):
			direction.x = 1
	if event.is_action_released("right"):
		direction.x = 0
		if Input.is_action_pressed("left"):
			direction.x = -1
	if event.is_action_released("up"):
		direction.y = 0
		if Input.is_action_pressed("down"):
			direction.y = 1
	if event.is_action_released("down"):
		direction.y = 0
		if Input.is_action_pressed("up"):
			direction.y = -1
		
	if event.is_action_pressed("left"):
		direction.x = -1
	elif event.is_action_pressed("right"):
		direction.x = 1
		
	if event.is_action_pressed("up"):
		direction.y = -1
	elif event.is_action_pressed("down"):
		direction.y = 1
		
func combat_mode() -> void:
	hitbox.disabled = false
	collision_box.disabled = true
	
func wander_mode() -> void:
	hitbox.disabled = true
	collision_box.disabled = false
	
func play_animation(anim : String) -> void:
	sprite.play(anim)
	
func run_neutral(delta : float):
	var new_anim : String = "default"
	
	if direction == Vector2.ZERO:
		new_anim = run_to_trans(sprite.animation)
	else:
		new_anim = direction_to_run(direction)
		
	if Input.is_action_just_pressed("dash"):
		dash()
	elif Input.is_action_just_pressed("parry"):
		state = State.PARRYING
	elif Input.is_action_just_released("attack"):
		state = State.ATTACKING
		attack_count = 0
		attack_lag = 0.0
		attack_buffer = "attack"
		sprite.stop()
	else:
		if Input.is_action_pressed("attack"):
			charge_count += delta
			
			if charge_count >= CHARGE_TIME:
				state = State.CHARGING
				charge_aura.show()
				charge_aura.frame = 0
				charge_aura.play("ignite")
				%hold_attack.begin_charge()
		else:
			charge_count = 0.0
			charge_aura.hide()
			%hold_attack.hide()
			
		sprite.play(new_anim)
		
func run_attacking(delta : float) -> void:
	if sprite.is_playing() or (attack_lag < MAX_LAG and attack_buffer == ""):
		attack_lag += delta
		
		if Input.is_action_just_pressed("attack"):
			attack_buffer = "attack"
		elif Input.is_action_just_pressed("dash"):
			attack_buffer = "dash"
		elif Input.is_action_just_pressed("parry"):
			attack_buffer = "parry"
	else:
		var attack_dir : String = ""
		var mouse_dir : Vector2 = Globals.get_direction_analog( \
			get_global_mouse_position(), get_true_position())
			
		var nearest_boss_coords : Vector2 = Vector2.ZERO
		var nearest_dir : Vector2 = Vector2.ZERO
		
		for boss in get_tree().get_nodes_in_group("Boss"):
			var dist : float = get_true_position().distance_to(boss.global_position)
			
			if dist < get_true_position().distance_to(nearest_boss_coords) or \
			nearest_boss_coords == Vector2.ZERO:
				nearest_boss_coords = boss.global_position
				
		if get_true_position().distance_to(nearest_boss_coords) > 200 or \
		nearest_boss_coords == Vector2.ZERO:
			nearest_dir = mouse_dir
		else:
			nearest_dir = Globals.get_direction_analog(nearest_boss_coords, get_true_position())
			
		if abs(nearest_dir.x) > abs(nearest_dir.y):
			if nearest_dir.x > 0:
				attack_dir = "e"
			else:
				attack_dir = "w"
		else:
			if nearest_dir.y > 0:
				attack_dir = "s"
			else:
				attack_dir = "n"
				
		attack_lag = 0.0
		
		match attack_buffer:
			"attack":
				attack_buffer = ""
				attack_count += 1
				sprite.play("attack_{0}_{1}".format([attack_dir, str(attack_count)]))
				
				if attack_count > 3:
					state = State.NEUTRAL
				%tap_attack.activate(nearest_dir)
			"dash":
				dash()
			"parry":
				state = State.PARRYING
			_:
				state = State.NEUTRAL
				
func run_charging(delta : float) -> void:
	var dir : Vector2 = Globals.get_direction_analog(get_global_mouse_position(), \
		get_true_position())
		
	%hold_attack.rotation = dir.angle() + PI / 2
	
	if dir.x < 0:
		sprite.play("charge_sw")
	else:
		sprite.play("charge_se")
		
	if Input.is_action_just_released("attack"):
		state = State.NEUTRAL # change this to after dash later
		%hold_attack.activate(dir)
		charge_aura.hide()
		
func run_parrying(delta : float) -> void:
	if sprite.animation == "parry":
		return
		
	if get_global_mouse_position().x < get_true_position().x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	if parry_count > 0.0:
		parry_count -= delta
		
		if Input.is_action_just_pressed("dash"):
			parry_buffer = "dash"
			
		if parry_count <= 0.0:
			match parry_buffer:
				"dash":
					dash()
				_:
					sprite.flip_h = false
					state = State.NEUTRAL
					
			parry_buffer = ""
	elif post_hit_count > 0.0:
		if Input.is_action_pressed("parry"):
			post_hit_count -= delta
			
			if post_hit_count <= 0.0:
				deal_damage(true, true)
		else:
			parry()
	elif not Input.is_action_pressed("parry"):
		parry_count = PARRY_WINDOW
	else:
		if sprite.animation == "block" and !sprite.is_playing():
			pass
		else:
			sprite.play("block")
			
func dash() -> void:
	if direction.x < 0:
		sprite.flip_h = true
		
	var dash_initial_dir : Vector2 = Vector2(direction.x, direction.y)
	var initial_intercardinal : bool = Globals.is_intercardinal(dash_initial_dir)
	
	state = State.DASHING
	sprite.play("dash_enter")
	
	await sprite.animation_finished
	
	var dash_final_dir : Vector2 = Vector2.ZERO
	var final_intercardinal : bool = Globals.is_intercardinal(direction)
	var subset : bool = Globals.is_subset(direction, dash_initial_dir)
	
	match direction:
		Vector2.ZERO:
			dash_final_dir = dash_initial_dir
		_:
			if initial_intercardinal and !final_intercardinal and subset:
				dash_final_dir = dash_initial_dir
			else:
				dash_final_dir = direction
				
	hitbox.disabled = true
	sprite.play("dash")
	%dash.activate(dash_final_dir)
	
	await %dash.finished
	
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	hitbox.disabled = false
	velocity = dash_final_dir * Vector2(MAX_SPEED, MAX_SPEED) / 1.5
	sprite.play("dash_exit")
	
	await sprite.animation_finished
	
	sprite.flip_h = false
	state = State.NEUTRAL
	
func parry() -> void:
	parry_count = 0.0
	post_hit_count = 0.0
	
	sprite.play("parry")
	parry_effect.show()
	parry_effect.play()
	
	await sprite.animation_finished
	
	parry_effect.hide()
	sprite.flip_h = false
	state = State.NEUTRAL
	
func get_true_position() -> Vector2:
	return hitbox.global_position
	
func deal_damage(ignore_block : bool = false, ignore_parry : bool = false) -> void:
	if parry_count > 0.0 and !ignore_parry:
		parry()
	elif state == State.PARRYING and !ignore_parry:
		post_hit_count = PARRY_WINDOW
	elif iframe_count > 0.0:
		pass
	else:
		health_container.remove_child(health_container.get_child(0))
		iframe_count = IFRAMES
		
		if health_container.get_child_count() == 0:
			# run animation before this
			emit_signal("player_death")
			
func direction_to_run(dir : Vector2) -> String:
	if dir in Globals.DIRECTIONS:
		return RUN_ANIMATIONS[Globals.DIRECTIONS.find(dir)]
	else:
		return "null"
		
func run_to_direction(anim : String) -> Vector2:
	if anim in RUN_ANIMATIONS:
		return Globals.DIRECTIONS[RUN_ANIMATIONS.find(anim)]
	else:
		return Vector2.ZERO
		
func run_to_trans(anim : String) -> String:
	if anim in RUN_ANIMATIONS:
		return TRANS_ANIMATIONS[RUN_ANIMATIONS.find(anim)]
	elif anim in TRANS_ANIMATIONS:
		return anim
	else:
		return "idle_east"
		
func trans_to_run(anim : String) -> String:
	if anim in TRANS_ANIMATIONS:
		return RUN_ANIMATIONS[TRANS_ANIMATIONS.find(anim)]
	elif anim in RUN_ANIMATIONS:
		return anim
	else:
		return "idle_east"
		
func _on_sprite_animation_looped() -> void:
	if sprite.animation in TRANS_ANIMATIONS:
		sprite.animation = "idle_east"
		
func _on_charge_aura_sprite_animation_looped() -> void:
	if charge_aura.animation == "ignite":
		charge_aura.animation = "steady"
