class_name Playwright extends AnimationPlayer

@export var dialogue_auto = true
@export var dialogue_allow_interrupt = false
@export var char_speed = 20.0
@export var dialogue_label: Label  
@export_file("*.txt") var dialogues_file: String
var dialogues = {}
var current_line = 0
var current_dialogue = ""
var has_dialogue_ended = true
var errand_list = []
var is_dialogue_playing = false
signal dialogue_line_ended()
signal dialogue_ended
var _dialogue_tween: Tween


class NoSwitchErrand extends Errand:
	func is_done() -> bool:
		return false
	func complete():
		pass
		

class ApproachErrand extends Errand:
	var actor: Actor
	var body: Node2D
	var radius = 10
	func is_done() -> bool:
		return Geometry2D.is_point_in_circle(actor.global_position, body.global_position, radius)
	func complete():
		playwright.play()
		
class PressActionErrand extends Errand:
	var action: String
	var repeat =0
	var commercial_animation = ""
	var commercial_player: AnimationPlayer
	var input = false
	func is_done() -> bool:
		input = input or Input.is_action_just_pressed(action)
		var animation = commercial_player.get_animation(commercial_animation)
		if animation.loop_mode == Animation.LoopMode.LOOP_NONE:
			if input and repeat >= 1:
				return true
			return false
		return input
	func complete():
		commercial_player.stop()
		playwright.play()
		print("DONE WITH THE press errand: " + str(playwright.current_animation_position))
	
class LeaveLevelAloneErrand extends Errand: 
	var door: Door
	var actor: Actor
	func complete():
		pass


class JumpActorErrand extends Errand: 
	var actor: Actor
	func complete():
		assert(playwright)
		playwright.play()
		print("FINISHED JUmping")
		
class PlayAnimationErrand extends Errand: 
	var animation: String
	var last_animation = ""
	var last_seek = 0
	func complete():	
		playwright.play(last_animation)
		playwright.seek(last_seek, true, true)

class PlayMusicErrand extends Errand: 
	var music: AudioStreamPlayer		
		
func is_allowing_switching_during_play():
	for errand in errand_list:
		if errand is PlayAnimationErrand:
			if errand.animation == &"hints/switch-player":
				return true
	return false
	
func is_allowing_moving_during_play():
	for errand in errand_list:
		if errand is PlayAnimationErrand:
			if errand.animation.contains("hints"):
				return false
	return true
		
func push_errand(errand: Errand) -> Errand:
	errand_list.append(errand)
	errand.playwright = self
	return errand

		
func jump_actor_errand(actor: NodePath):
	var errand = push_errand(JumpActorErrand.new())
	errand.actor = get_node(actor)
	errand.actor.jumped.connect(func():
		errand.force_complete()
		, CONNECT_ONE_SHOT)
	pause()
		
func play_animation_errand(animation: String):
	var errand = push_errand(PlayAnimationErrand.new())
	errand.last_seek = current_animation_position
	errand.last_animation = current_animation
	errand.animation = animation
	play(animation)
	animation_finished.connect(func(anim: StringName):
		if anim == errand.animation:
			errand.force_complete()
		, CONNECT_ONE_SHOT)

var music_tween: Tween
func toggle_music_errand(music: NodePath, is_singleton: bool = true, last_music_fade = 1.0):
	var music_node: AudioStreamPlayer = get_node(music)
	var remove = null
	for errand in errand_list:
		if errand is PlayMusicErrand and (errand.music == music_node or is_singleton):
			remove = errand
	if remove:
		errand_list.erase(remove)
		music_tween = create_tween()
		var last_volume = remove.music.volume_db
		music_tween.tween_property(remove.music, "volume_db", 0, last_music_fade)
		music_tween.tween_callback(func():
			remove.music.stop()
			remove.music.volume_db = last_volume
			if remove.music != music_node or is_singleton:
				var errand = push_errand(PlayMusicErrand.new())
				errand.music = music_node
				errand.music.play()
			)
	else:
		var errand = push_errand(PlayMusicErrand.new())
		errand.music = music_node
		errand.music.play()

func can_switch_with_hint():
	for errand in errand_list:
		if errand is NoSwitchErrand:
			return false
	return true

func toggle_no_switch():
	var remove = null
	for errand in errand_list:
		if errand is NoSwitchErrand:
			remove = errand
	if remove:
		errand_list.erase(remove)
	else:
		push_errand(NoSwitchErrand.new())

func leave_level_alone_errand(actor: NodePath, door: NodePath, command = ""):
	var errand = push_errand(LeaveLevelAloneErrand.new())
	errand.actor = get_node(actor)
	errand.door = get_node(door)
	print("Trying to leave")

	errand.door.within_range_solo.connect(func(): 
		errand.actor.visible = false
		errand.actor.process_mode = ProcessMode.PROCESS_MODE_DISABLED
		errand.force_complete()
		, CONNECT_ONE_SHOT)
		
func press_action_errand(action: String):
	var errand = push_errand(PressActionErrand.new())
	errand.action = action
	pause()
	
func press_action_while_animating_errand(action: String, player: NodePath, anim: String):
	pause()
	var errand = push_errand(PressActionErrand.new())
	errand.action = action
	errand.commercial_animation = anim
	errand.commercial_player = get_node(player)
	errand.commercial_player.play(errand.commercial_animation)
	var animation: Animation = errand.commercial_player.get_animation(anim)
	if animation.loop_mode == Animation.LoopMode.LOOP_NONE:
		var repeat = func(a: String, callback: Callable):
			if a == anim:
				errand.repeat+=1
				errand.commercial_player.play(errand.commercial_animation)
				errand.commercial_player.animation_finished.connect(func(a: String): 
					callback.call(a, callback)
				, CONNECT_ONE_SHOT)
		errand.commercial_player.animation_finished.connect(func(a: String): 
			repeat.call(a, repeat)
			, CONNECT_ONE_SHOT)

	

func cage_unlock_errand(cage: NodePath):
	var errand = push_errand(Cage.UnlockedErrand.new())
	errand.cage = get_node(cage)
	errand.cage.key_detect.connect(func():
		errand.has_unlocked = true
		)
	pause()
		
func approach_errand(actor: NodePath, point: NodePath, radius = 30):
	var errand = push_errand(ApproachErrand.new())
	errand.actor = get_node(actor)
	errand.body = get_node(point)
	errand.radius = radius
	pause()
	
func use_item_errand(actor: NodePath, item_name: String):
	var errand = push_errand(Key.UseErrand.new())
	errand.actor = get_node(actor)
	if item_name == "Key":
		for item in errand.actor.items:
			if item is Key:
				errand.item = item
				item.use()
	pause()
	
func has_key_errand(actor: NodePath):
	var errand = push_errand(Key.HasKeyErrand.new())
	errand.actor = get_node(actor)
	pause()

func is_in_cutscene() -> bool:
	var value = false
	for errand in errand_list:
		if errand is ApproachErrand or errand is JumpActorErrand:
			value = true
	return value or (active and is_playing()) or not has_dialogue_ended
	

func _ready() -> void:
	var dialogue_content = FileAccess.open(dialogues_file, FileAccess.READ).get_as_text()
	var line_groups = dialogue_content.split("\n\n")
	for line_group in line_groups:
		var lines = line_group.split("\n")
		assert(lines.size()>1)
		var idx = lines[0]
		dialogues[idx] = []
		for line in lines.slice(1, lines.size()):
			if line:
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
	if paused:
		pause()
	print("attempt to play dialogue: " + dialogue_idx)
	current_dialogue = dialogue_idx
	current_line = 0
	next_dialogue()
	
	
func play_dialogue_auto(dialogue_idx: String, callable: Callable):
	if current_dialogue != "":
		return
	var last_auto = dialogue_auto
	dialogue_auto = true
	play_dialogue(dialogue_idx, true)
	dialogue_ended.connect(func():
		dialogue_auto = last_auto
		callable.call()
		, CONNECT_ONE_SHOT)
	

func _input(event: InputEvent) -> void:
	if current_dialogue != "" and not dialogue_auto and event.is_action_released("continue_dialogue"): 
		if dialogue_allow_interrupt:
			_dialogue_tween.custom_step(char_speed); 
		if not _dialogue_tween.is_valid():
			if current_line < get_dialogue_lines().size()-1:
				current_line += 1
				next_dialogue()
			else: 
				dialogue_ended.emit()
		get_viewport().set_input_as_handled()
		
		
func _process(_delta: float) -> void:
	var inactive_errand = []
	for errand in errand_list:
		if errand.is_done():
			errand.complete()
			inactive_errand.append(errand)
	for errand in inactive_errand:
		errand_list.erase(errand)
	
	
