extends AnimationPlayer

@export var dialogue_auto = true
@export var dialogue_allow_interrupt = false
@export var char_speed = 20
@export var dialogue_label: Label  
@export_file("*.txt") var dialogues_file: String
var dialogues = {}
var current_line = 0
var current_dialogue = ""
var has_dialogue_ended = true
var errand = NoErrand.new()		
var is_dialogue_playing = false
signal dialogue_line_ended()
signal dialogue_ended
var _dialogue_tween: Tween


class Errand:
	func is_done() -> bool:
		assert(false)
		return false
		
class NoErrand extends Errand:
	func is_done() -> bool:
		assert(false)
		return false
	
class ApproachErrand:
	var actor: Actor
	var body: Actor
	func is_done() -> bool:
		return Geometry2D.is_point_in_circle(actor.global_position, body.global_position, actor.item_magnet_radius+body.item_magnet_radius)
		
class HasKeyErrand:
	var actor: Actor
	func is_done() -> bool:
		for item in actor.items:
			if item is Key:
				return true
		return false
		
class UseItemErrand:
	var actor: Actor
	var item: Key
	func is_done() -> bool:
		return item.is_done_using()
		
func approach_errand(actor: NodePath, body: NodePath):
	errand = ApproachErrand.new()
	errand.actor = get_node(actor)
	errand.body = get_node(body)
	pause()
	
func use_item_errand(actor: NodePath, item_name: String):
	errand = UseItemErrand.new()
	errand.actor = get_node(actor)
	if item_name == "Key":
		for item in errand.actor.items:
			if item is Key:
				errand.item = item
				item.use()
	pause()
	
func has_key_errand(actor: NodePath):
	errand = HasKeyErrand.new()
	errand.actor = get_node(actor)
	pause()

func is_in_cutscene() -> bool:
	return (active and is_playing()) or not has_dialogue_ended
	

func _ready() -> void:
	var dialogue_content = FileAccess.open(dialogues_file, FileAccess.READ).get_as_text()
	var line_groups = dialogue_content.split("\n\n")
	for line_group in line_groups:
		var lines = line_group.split("\n")
		assert(lines.size()>1)
		var idx = lines[0]
		dialogues[idx] = []
		for line in lines.slice(1, lines.size()):
			dialogues[idx].append(line)

	print(dialogues)
	dialogue_ended.connect(func():
		dialogue_label.visible_characters = 0
		has_dialogue_ended = true
		current_dialogue = ""
		play())
	dialogue_line_ended.connect(func():
		)

func _animate_dialogue(on_finished_line: Callable):
	dialogue_label.visible_characters = 0
	_dialogue_tween = create_tween()
	_dialogue_tween.tween_property(
		dialogue_label, 
		"visible_characters", 
		dialogue_label.text.length(), 
		maxf(dialogue_label.text.length() / char_speed, 0.5))
	_dialogue_tween.tween_callback(func():
		dialogue_line_ended.emit()
		)
	
	if dialogue_auto:
		_dialogue_tween.tween_callback(func(): 
			if current_line + 1 < get_dialogue_lines().size():
				current_line += 1
				on_finished_line.call()
			else:
				dialogue_ended.emit()
			).set_delay(1)
		
func get_dialogue_lines():
	return dialogues[current_dialogue]
			
func next_dialogue():
	has_dialogue_ended = false
	var message = dialogues[current_dialogue][current_line]
	assert(message)
	dialogue_label.text = message
	_animate_dialogue(next_dialogue)
	
func pause_until_approach(actor: Actor, body: Area2D):
	body.overlaps_body(actor)
		
func play_dialogue(dialogue_idx: String, paused: bool = true):
	pause()
	current_dialogue = dialogue_idx
	current_line = 0
	next_dialogue()
		
func _process(delta: float) -> void:
	if errand is not NoErrand and errand.is_done():
		errand = NoErrand.new()
		play()
	
	if current_dialogue != "" and not dialogue_auto and Input.is_action_just_released("continue_dialogue"): 
		if dialogue_allow_interrupt:
			_dialogue_tween.custom_step(char_speed); 
		if not _dialogue_tween.is_valid():
			if current_line < get_dialogue_lines().size()-1:
				print("next")
				current_line += 1
				next_dialogue()
			else: 
				print("ended")
				dialogue_ended.emit()
