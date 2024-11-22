extends "res://Game/attack.gd"

@export var charge_rate : float = 1.4
@export var max_charge : int = 3200

@onready var tip_starting_y : int = %tip.position.y

var charge : int = 0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if visible:
		charge = lerp(charge, max_charge, sin((charge_rate / 100) * PI / 2))
	else:
		charge = 0
		
	%tip.position.y = tip_starting_y - charge
	
	var shaft_extension : int = %base.position.y - %tip.position.y + 40
	
	%shaft.position.y = %tip.position.y + 140
	%shaft/left.size.y = shaft_extension
	%shaft/middle.size.y = shaft_extension
	%shaft/right.size.y = shaft_extension
	
func begin_charge() -> void:
	show()
	$charge_arrow.show()
	
func activate(dir : Vector2) -> void:
	super(dir)
	
	caster.position = %tip.global_position
	$charge_arrow.hide()
