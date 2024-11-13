extends Node2D

@onready var canvas_modulate = $canvas_layer/modulate
@onready var portrait_left = $canvas_layer/portrait_left
@onready var portrait_right = $canvas_layer/portrait_right
@onready var box = $canvas_layer/dialog_box
@onready var label = $canvas_layer/label
@onready var choice_1 = $canvas_layer/choice_top
@onready var choice_2 = $canvas_layer/choice_bottom

var portraits : Dictionary = {} # <String, Texture>
var dialogue : Array = [] # <Array<String>>

var index : int = 0
var allow_input : bool = true

signal finished
signal choice_made(choice : int)

func _ready() -> void:
	choice_1.get_node("button").pressed.connect(choice_1_selected)
	choice_2.get_node("button").pressed.connect(choice_2_selected)
	
	advance_dialogue()
	fade_in()
	
func _enter_tree() -> void:
	$canvas_layer/modulate.color.a = 0.0
	$canvas_layer/label.text = ""
	
	$canvas_layer/dialog_box.play()
	
func _process(delta : float) -> void:
	if Input.is_action_just_pressed("advance") and allow_input:
		advance_dialogue()
	
func init_scene_from_dialogue(dialogue : Array) -> void:
	self.dialogue = dialogue
	
	var speakers : Array = [] # <String>
	
	for line in dialogue:
		var speaker : String
		
		match line[0]:
			"show":
				speaker = get_proper_name(line[1])
			"choice", "branch", "jump_to":
				continue
			_:
				speaker = get_proper_name(line[0])
		
		if speaker not in speakers:
			speakers.append(speaker)
			
	for speaker in speakers:
		load_portraits("res://Assets/UI/Portraits/" + speaker)
		
func load_portraits(path : String) -> void:
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				var file_path = path + "/" + file_name
				var texture = load(file_path)
				
				if texture:
					portraits[remove_suffix(file_name)] = texture
					
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		push_error("directory doesn't exist dumbass: " + path)
		
func get_proper_name(input : String) -> String:
	return input.split("_")[0].capitalize()
	
func remove_suffix(input : String) -> String:
	return input.split(".png")[0]
	
func advance_dialogue() -> void:
	if index > dialogue.size() - 1:
		fade_out()
		return
		
	var line : Array = dialogue[index]
	var type : String = line[0]
	
	index += 1
	
	match type:
		"show":
			show_speaker(line[1])
			advance_dialogue()
		"choice":
			allow_input = false
			
			var choice_1_text = line[1]
			var choice_2_text = line[2]
			
			var choice_1_path = dialogue[index][1]
			var choice_2_path = dialogue[index][2]
			
			choice_1.show()
			choice_2.show()
			
			choice_1.get_node("label").text = choice_1_text
			choice_2.get_node("label").text = choice_2_text
			
			var choice = await choice_made
			
			choice_1.hide()
			choice_2.hide()
			
			allow_input = true
			
			match choice:
				1:
					init_scene_from_dialogue(choice_1_path)
				2:
					init_scene_from_dialogue(choice_2_path)
					
			index = 0
			advance_dialogue()
		"jump_to":
			var new_dialogue : Array = line[1]
			
			index = 0
			init_scene_from_dialogue(new_dialogue)
		_:
			show_speaker(line[0])
			label.text = line[1]
			
func choice_1_selected() -> void:
	emit_signal("choice_made", 1)
	
func choice_2_selected() -> void:
	emit_signal("choice_made", 2)
	
func show_speaker(speaker : String) -> void:
	if get_proper_name(speaker) == "Ethan":
		portrait_left.texture = portraits[speaker]
	else:
		portrait_right.texture = portraits[speaker]
		
func fade_in() -> void:
	box.show()
	label.show()
	create_tween().tween_property(canvas_modulate, "color:a", 1.0, 0.8)
	
func fade_out() -> void:
	await create_tween().tween_property(canvas_modulate, "color:a", 0.0, 0.8).finished
	emit_signal("finished")
	
	get_parent().remove_child(self)
	queue_free()
