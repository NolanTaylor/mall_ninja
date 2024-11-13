extends Area2D

@export_category("Collision Settings")
@export var hits_enemy : bool = false
@export var hits_player : bool = false
@export var hits_terrain : bool = false

@export_category("On-Hit Settings")
@export var damage : int = 1
@export var parriable : bool = false

@export_category("Persistence Settings")
@export var destroy_on_hit : bool = false
@export var destroy_after_time : float = 0.0

var caster : Node = null
var act : int = 0

signal finished

func _ready() -> void:
	hide()
	
	$sprite.animation_looped.connect(cancel)
	
func _physics_process(delta: float) -> void:
	pass
	
func set_caster(caster : Node) -> void:
	self.caster = caster
	
func set_flip_h(flip : bool) -> void:
	$sprite.flip_h = flip
	
func activate(dir : Vector2) -> void:
	show()
	
	if destroy_after_time > 0.0:
		await get_tree().create_timer(destroy_after_time).timeout
		
		destroy()
		
func cancel() -> void:
	$sprite.stop()
	hide()
	
func collision(body : Node) -> void:
	if body.has_method("deal_damage"):
		body.deal_damage(damage)
		
	if destroy_on_hit:
		destroy()
		
func parried() -> void:
	pass
	
func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()
	
func apply_collisions() -> void:
	for body in get_overlapping_bodies():
		_on_body_entered(body)
		
func _on_body_entered(body: Node2D) -> void:
	var hit_flag : bool = false
	
	if body.is_in_group("Boss") and hits_enemy:
		hit_flag = true
	if body.is_in_group("Player") and hits_player:
		hit_flag = true
		
	if hit_flag:
		collision(body)
