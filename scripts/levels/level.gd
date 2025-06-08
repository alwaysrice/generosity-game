class_name Level extends Node2D

var has_entered_through_door = false
@onready var cutscenes = $Cutscenes
@onready var camera = $Camera
@export var enable_player_lights = false

func switch_witch(): switch_player(%Witch)
	
func no_player():
	%Witch.is_player = false
	%Cat.is_player = false
	%Witch.velocity = Vector2.ZERO
	%Cat.velocity = Vector2.ZERO
	
func switch_player(who: Actor = null) -> Actor:
	if %Witch.process_mode == ProcessMode.PROCESS_MODE_DISABLED or %Cat.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		return null
	if !who:
		assert(%Cat.is_player != %Witch.is_player)
		%Cat.is_player = !%Cat.is_player
		%Witch.is_player = !%Witch.is_player
		who = %Witch as Actor if %Witch.is_player else %Cat as Actor
	else:
		%Cat.is_player = false
		%Witch.is_player = false
		
	%Camera.enabled = true
	who.is_player = true
	%Camera.target = who
	
	return who
	
func open_eye():
	for child in get_children():
		if child is Door:
			child.open_eye()
			
var _last_music_position = 0.0
var _last_volume = 0.0
func fade_music_to_stop(time: float, callable: Callable = func(): pass):
	var tween = create_tween()
	var music = $Music as AudioStreamPlayer
	_last_music_position = music.get_playback_position()
	_last_volume = music.volume_db
	tween.tween_property(music, "volume_db", -60, time)
	tween.tween_callback(func():
		music.stop()
		callable.call()
		)
	
func face_music_resume(time: float, callable: Callable = func(): pass):
	var tween = create_tween()
	var music = $Music as AudioStreamPlayer
	music.volume_db = -60
	music.play(_last_music_position)
	tween.tween_property(music, "volume_db", _last_volume, time)
	tween.tween_callback(callable)
	

func get_bounds() -> Rect2:
	var rect = Rect2(10000, 10000, 0, 0)
	var limits =  $Graphics.get_node_or_null("ScreenLimits")
	if limits is ColorRect:
		rect.position = limits.get_rect().position
		rect.size = limits.get_rect().position + limits.get_rect().size
	for child in $Graphics/Background.get_children(true):
		if child is Sprite2D:
			rect.position.x = min(child.global_position.x, rect.position.x)
			rect.position.y = min(child.global_position.y, rect.position.y)
			rect.size.x = max(child.global_position.x + child.texture.get_size().x * child.scale.x, rect.size.x)
			rect.size.y = max(child.global_position.y + child.texture.get_size().y * child.scale.y, rect.size.y)

		
	return rect
	
func get_nyota() -> Witch:
	return %Witch
	
var is_once = true
func _ready() -> void:	
	if not is_once: return
	if not cutscenes.active or not cutscenes.autoplay:
		%Witch.should_follow = true
		%Cat.should_follow = true
		$%Camera.zoom = Vector2.ONE
		switch_witch()
	
	var bounds := get_bounds()
	for child in get_children():
		if child is Key:
			child.body_entered.connect(_on_key_body_entered)
			
	for child in $Graphics/Objects.get_children():
		if child is Door:
			child.wants_to_enter.connect(func(): _on_enter_door(child))
			
	for child in $Graphics/Characters.get_children():
		if child is Actor:
			child.on_death.connect(_on_death)	
			

	%Witch.hint_fly_interruped.connect(func():
		%Witch.start_flight()
		#%Cat.should_follow = false
		%Witch.following.is_joining = false
		#$Cutscenes.play_dialogue_auto("91", func():
			#%Cat.should_follow = true 
			#)
		#prevent_movement = false
		#following.is_joining = false
		#_on_flight_timer_timeout()
		)
			
	_connect_boundaries()
			
	print(bounds)
	assert(%Camera)
	%Camera.limit_left = int(bounds.position.x)
	%Camera.limit_top = int(bounds.position.y) 
	%Camera.limit_right = int(bounds.size.x)
	%Camera.limit_bottom = int(bounds.size.y) 
	
	cutscenes.animation_finished.connect(func(anim: String): 
		if anim == "trans/enter_level":
			if cutscenes.autoplay == "story/scene":
				cutscenes.play("story/scene")
		, CONNECT_ONE_SHOT)
	
	is_once = false
	
	
	
func _unhandled_input(event: InputEvent) -> void:		
	if event.is_action_pressed(&"switch_character") && not $Cutscenes.is_in_cutscene():
		if not $Cutscenes.can_switch_with_hint():
			$Cutscenes.play_animation_errand(&"hints/cannot-switch")
			return
		var new_player = switch_player()
		if not new_player:
			return
		if new_player.following is Actor:
			new_player.following.velocity = Vector2.ZERO
			new_player._on_switch(new_player.following)
		else:
			new_player._on_switch(null)
		
		
func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug_1"):
		$Env.environment.glow_enabled = not $Env.environment.glow_enabled
		if not $Env.environment.glow_enabled:
			$Graphics/Background.modulate = Color.WHITE
		else:
			$Graphics/Background.modulate = Color.hex(0xb8b8b8ff)
	var max_top = camera.limit_top + camera.limit_bottom
	
	if enable_player_lights:
		%Witch.set_light_ratio(%Witch.global_position.y / max_top)
		%Cat.set_light_ratio(%Cat.global_position.y / max_top)
	else:
		%Witch.set_light_ratio(0)
		%Cat.set_light_ratio(0)


func _on_key_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
	

func _on_deadzone_body_entered(body: Node2D) -> void:
	var actor = body as Actor
	actor.die()

func _on_death(actor: Actor) -> void:
	actor.revive()
	
func _on_enter_level_boundary(boundary: LevelConnectBoundary):
	enter_new_level(boundary.connected_level)

func _on_enter_door(door: Door):
	if not $Cutscenes.is_in_cutscene(): 
		enter_new_level(door.destination)
		
func enter_new_level(level_path: String):
	var new_level = GameManager.load_level(level_path)
	var parent = get_parent()
	
	if parent and parent.get_parent() is Game:
		cutscenes.active = true
		new_level.ready.connect(func():
			%Cat.visible = true
			%Cat.process_mode = ProcessMode.PROCESS_MODE_INHERIT
			new_level.cutscenes.active = true
			new_level.cutscenes.play("trans/enter_level")
			new_level.cutscenes.animation_finished.connect(func(anim: StringName):
				var tween = create_tween()
				tween.tween_callback(func():_connect_boundaries()).set_delay(0.5)
				#tween.tween_callback(func():
					#print("ENTER")
					#if new_level is Corridor:
						#print("IS CORRIDor")
						#if new_level.can_play_scene:
							#new_level.can_play_scene = false
							#new_level.get_node("Cutscenes").play("story/scene")
					#)
				, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
		cutscenes.play("trans/leave_level")
		cutscenes.animation_finished.connect(func(anim: StringName):
			spawn_closest_boundary()
			parent = parent.get_parent()
			if parent.level.get_child(0):
				parent.level.remove_child(parent.level.get_child(0))
			new_level.request_ready()
			parent.level.add_child(new_level)
		, CONNECT_ONE_SHOT)
		
		
		
func _connect_boundaries():
	for child in $Graphics/Objects.get_children():
		if child is LevelConnectBoundary:
			child.body_entered.connect(func(body: Node2D): _on_enter_level_boundary(child), CONNECT_ONE_SHOT)


func spawn_closest_boundary():
	var left_dist = absf(%Witch.global_position.x - %SpawnLeft.global_position.x)
	var right_dist = absf(%Witch.global_position.x - %SpawnRight.global_position.x)
	if left_dist < right_dist:
		%Witch.global_position = %SpawnLeft.global_position
		%Cat.global_position = %SpawnLeft2.global_position
		%Witch.turn_right()
		%Cat.turn_right()
	else:
		%Witch.global_position = %SpawnRight.global_position
		%Cat.global_position = %SpawnRight2.global_position
		%Witch.turn_left()
		%Cat.turn_left()
	%Witch.stop()
	%Cat.stop()

var on_entered_level = _on_entered_level
func _on_entered_level():
	print("DEFAULT")
			
func _on_lone_chara_enter_door():
	pass


func _on_deadzone_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass
