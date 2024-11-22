extends CharacterBody2D

@export var cutscene_mode : bool = false
@export var speed : int = 320
@export var starting_health : int = 10

@onready var health : int = starting_health

var player : Node = null

var phase : int = 0
var state : int = 0

signal spawn_entity(entity : Node)
signal collision(collider : KinematicCollision2D)

func _ready() -> void:
	add_to_group("Boss")
	
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		emit_signal("collision", collision)
		
func set_player(player : Node) -> void:
	self.player = player
	
func deal_damage() -> void:
	pass
	
func play_animation(anim : String) -> void:
	# needs override if animated sprite is different
	if has_node("sprite"):
		get_node("sprite").play(anim)
		
