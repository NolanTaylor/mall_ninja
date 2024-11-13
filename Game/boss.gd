extends CharacterBody2D

@export var cutscene_mode : bool = false
@export var speed : int = 320
@export var starting_health : int = 10

@onready var health : int = starting_health

var player : Node = null

var state : int = 0

signal spawn_entity(entity)

func _ready() -> void:
	add_to_group("Boss")
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
func set_player(player : Node) -> void:
	self.player = player
	
func deal_damage(dmg : int, source : Node = player) -> void:
	health -= dmg
	
func play_animation(anim : String) -> void:
	# needs override if animated sprite is different
	if has_node("sprite"):
		get_node("sprite").play(anim)
		
