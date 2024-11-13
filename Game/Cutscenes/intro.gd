extends "res://Game/cutscene.gd"

@onready var player = $player
@onready var paul = $paul
@onready var fade = $fade_black
@onready var mall = $mall_exterior
@onready var ethan = $mall_exterior_ethan
@onready var entrance = $mall_entrance
@onready var signs = $mall_entrance_signs

func _enter_tree() -> void:
	$fade_black.modulate.a = 1.0
	$fade_black.show()

func _ready() -> void:
	mall.show()
	ethan.show()
	tween(mall, "position:x", 0, 2.4)
	tween(ethan, "position:x", 0, 2.4)
	await tween(fade, "modulate:a", 0.0, 1.6)
	await wait(1.4)
	entrance.show()
	signs.show()
	player.position = Vector2(563, 872)
	player.show()
	tween(mall, "modulate:a", 0, 0.8)
	tween(ethan, "modulate:a", 0, 0.8)
	await wait(1.2)
	player.play_animation("run_n")
	tween(signs, "position:y", -334, 2.0)
	await tween(player, "position", Vector2(564, 404), 2.2)
	player.play_animation("idle_east")
	await wait(0.8)
	await play_dialogue(Dialogue.INTRO)
	await wait(0.8)
	paul.show()
	paul.position = Vector2(953, -98)
	paul.play_animation("run_s")
	await tween(paul, "position", Vector2(948, 127), 1.0)
	paul.play_animation("run_se")
	paul.scale.x = -1
	await tween(paul, "position", Vector2(748, 230), 1.0)
	paul.scale.x = 1
	paul.play_animation("run_s")
	await tween(paul, "position", Vector2(744, 340), 1.0)
	paul.play_animation("idle")
	await wait(0.8)
	await play_dialogue(Dialogue.INTRO_PAUL)
	paul.play_animation("run_brake_e")
	await tween(paul, "position", Vector2(900, 331), 0.6)
	paul.play_animation("pull_gun")
	await wait(0.2)
	GameManager.go_to_scene("paul_fight")
