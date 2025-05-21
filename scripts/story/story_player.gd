extends AnimationPlayer

@export var dialogue_auto = true
@export var dialogue_allow_interrupt = false
@export var char_speed = 20
@export var dialogue_label: Label  
@export_multiline var dialogues: PackedStringArray
var current_line = 0
var current_dialogue = 0
var dialogue_finished_animating = false

signal dialogue_ended
	
var _dialogue_tween = create_tween()

func _ready() -> void:
	dialogue_ended.connect(func():
		dialogue_finished_animating = true
		dialogue_label.visible_characters = 0
		play())

func _animate_dialogue(on_finished_line: Callable):
	dialogue_label.visible_characters = 0
	_dialogue_tween = create_tween()
	_dialogue_tween.tween_property(
		dialogue_label, 
		"visible_characters", 
		dialogue_label.text.length(), 
		dialogue_label.text.length() / char_speed)
	
	_dialogue_tween.tween_callback(func(): 
		if dialogue_auto and current_line + 1 < get_dialogue_lines().size():
			current_line += 1
			on_finished_line.call()
		else:
			dialogue_ended.emit()
		).set_delay(1)
		
func get_dialogue_lines():
	return dialogues[current_dialogue].split("\n")
			
func next_dialogue():
	dialogue_finished_animating = false
	var lines = dialogues[current_dialogue].split("\n")
	var line = lines[current_line].split(">>")
	var sender = line[0]
	var message = line[1]
	dialogue_label.text = message
	_animate_dialogue(next_dialogue)
		
func play_dialogue(dialogue_idx: int, paused: bool = true):
	pause()
	current_dialogue = dialogue_idx
	current_line = 0
	next_dialogue()
		
func _process(delta: float) -> void:
	if not dialogue_auto and Input.is_action_just_released("continue_dialogue"): 
		if dialogue_allow_interrupt:
			_dialogue_tween.custom_step(char_speed); 
		if (!_dialogue_tween.is_valid() && current_line < get_dialogue_lines().size()-1):
			current_line += 1
			next_dialogue()
		else: 
			dialogue_ended.emit()


#witch>>“Huh? What happened…? Where am I?”
#witch>>“A cage?”
#witch>>“Wait, where’s—”
