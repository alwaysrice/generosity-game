class_name Actor extends CharacterBody2D

@export var walk_speed = 100.0
@export var run_speed = 300.0
@export var walk_accel = 6.0
@export var run_accel = 6.0
@export var jump_speed = -725.0
@export var fall_speed_max = 700
@export var follow_distance = 100
@export var follow_distance_run = 200
@export var item_magnet_radius = 100
@export var allow_double_jump = false

@export var following: Node2D
@export var should_follow = false
@export var is_player := false

@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var graphics := $Graphics as Node2D

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
var can_double_jump := false
var should_jump := false
var is_jumping := false
var is_flying := false
var is_dead := false
var prevent_movement := false

var last_floor_stepped: StaticBody2D
var last_floor_stepped_pos := Vector2.ZERO
var last_direction := 0
var items = []
var action_history = []
@export var follow_object_minimum = 5
@export var is_follow_object_walk_only = true
@export var is_follow_object_run = false
var is_joining = false
var has_joined_other = false
var light_overlay_modulate = 0
var light_spread_energy = 0

signal towards_next_level(boundary: LevelConnectBoundary)
signal on_follow
signal on_follow_close
signal on_death(actor: Actor)
signal jump_landed
signal jumped 


func _ready() -> void:
	light_overlay_modulate = %OverlayLight.modulate
	light_spread_energy = %SpreadLight.energy
	

func set_light_ratio(value: float):
	value = clampf(value, 0.0, 1.0)
	%OverlayLight.modulate.a = value
	%SpreadLight.energy = value * light_spread_energy

func follow(who: NodePath):
	following = get_node_or_null(who)
	if not following:
		velocity = Vector2.ZERO
		
func stop():
	velocity = Vector2.ZERO
	is_jumping = false

func revive():
	#if following and absf(following.global_position.x - global_position.x) >= run_speed:
	is_dead = false
	graphics.modulate = Color.WHITE
	
	assert(last_floor_stepped)
	position = last_floor_stepped_pos

func die():
	$DeathEffect.emitting = true
	graphics.modulate = Color.TRANSPARENT
	is_dead = true
	
func spellcast():
	get_sprite().play("spellcast")
	get_sprite().animation_finished.connect(func():
		get_sprite().play("idle")
		print("finished asdfasdf")
		, CONNECT_ONE_SHOT)

func is_follow_object():
	return following is not Actor or following.process_mode == ProcessMode.PROCESS_MODE_DISABLED

func afk_behaviour(delta: float):
	if not following or not should_follow or has_joined_other: return

	var dist = following.global_position - global_position
	var speed = walk_speed
	var accel = walk_accel
	var is_follow_object = following is not Actor or following.process_mode == ProcessMode.PROCESS_MODE_DISABLED
	var is_far = dist.x > follow_distance_run || dist.x < -follow_distance_run
	if is_follow_object:
		if (not is_follow_object_walk_only and is_far) or is_follow_object_run:
			speed = run_speed	
			accel = run_accel
	elif is_far:
		speed = run_speed	
		accel = run_accel
		
	var follow_dist = follow_distance 
	if is_follow_object:
		follow_dist = follow_object_minimum
	
	if is_jumping:
		velocity.x = move_toward(velocity.x, sign(velocity.x) * run_speed, run_accel * run_speed * delta)
	elif dist.x > follow_dist || dist.x < -follow_dist:
		velocity.x = move_toward(velocity.x, sign(dist.x) * speed, accel * speed * delta)
		on_follow.emit()
	else:
		velocity.x = move_toward(velocity.x, 0, accel * speed * delta)
		on_follow_close.emit()
		
	if %CliffDetector.is_colliding() and velocity.x != 0.0:
		try_jump()
	
func turn_left():
	graphics.scale.x = -1
	
func turn_right():
	graphics.scale.x = 1
	
func _input(event):
	if prevent_movement: return
	if event.is_action_pressed("move_right"):
		last_direction = 1
	elif event.is_action_pressed("move_left"):
		last_direction = -1
		
func get_sprite() -> AnimatedSprite2D: 
	return graphics.get_child(0)
		
func get_input_direction():
	if prevent_movement: return 0
	var right = Input.is_action_pressed("move_right")
	var left = Input.is_action_pressed("move_left")
	if right and left:	return last_direction
	elif right: return 1
	elif left: return -1
	return 0

		
func _physics_process(delta: float) -> void:
	if is_dead: return
	if is_on_floor():
		can_double_jump = true
		
	var can_move = get_sprite().animation != "pet"
	if is_player and (Input.is_action_just_pressed("jump") or should_jump) and can_move:
		try_jump()
		get_viewport().set_input_as_handled()
		
	# Continously fall due to gravity 
	if not is_flying and not has_joined_other:
		velocity.y = minf(fall_speed_max, velocity.y + gravity * delta)
	
	# Turn around based on movement
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			graphics.scale.x = 1
			turn_right()
		else:
			graphics.scale.x = -1
			turn_left()
	
	if is_player:
		if can_move: 
			var speed = walk_speed
			var accel = walk_accel
			if Input.is_action_pressed("run"):
				speed = run_speed
				accel = run_accel
		
			var direction: float = get_input_direction() * speed * int(is_player)
			velocity.x = move_toward(velocity.x, direction, accel * speed * delta)
	
	# If flying with other chara
	elif has_joined_other:
		velocity = following.velocity
		if self is Cat:
			global_position = following.graphics.get_node("Broom/Dest").global_position
			global_position -= %Offset.position

	# Other chara is the player
	else:
		afk_behaviour(delta)


	if $FloorDetector.is_colliding():
		last_floor_stepped = $FloorDetector.get_collider()
		last_floor_stepped_pos = position
		
	if $%NextLevelDetector.is_colliding():
		var boundary = $Graphics/NextLevelDetector.get_collider()
		if boundary is LevelConnectBoundary:
			towards_next_level.emit(boundary)
		
	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()
	
	var animation := get_new_animation()
	var sprite = $Graphics.get_child(0)
	if sprite is AnimatedSprite2D and sprite.animation != animation and not is_flying and not has_joined_other and not sprite.animation == "spellcast" and not sprite.animation == "pet":
		animation_history.append(animation)
		sprite.play(animation)
		

var animation_history = []
func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if is_player:
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				animation_new = "walk"
			else:
				animation_new = "idle"
		else:
			if absf(velocity.x) > 0.1:
				animation_new = "walk"
			else:
				animation_new = "idle"
		if is_jumping and (animation_history.back() == "fall" or animation_history.back() == "idle"):
			print("LANDED")
			jump_landed.emit()
			if animation_history.size() > 10:
				animation_history.clear()
				animation_history.append("idle")
		is_jumping = false
	else:
		if velocity.y > 0.0:
			animation_new = "fall"
			jumped.emit()
		else:
			animation_new = "jump"
			
	if is_player and Input.is_action_pressed("run") and animation_new == "walk":
		animation_new = "run"
	return animation_new


func try_jump() -> void:
	if is_dead: return
	if is_on_floor():
		$JumpSound.pitch_scale = 1.0
		is_jumping = true
		animation_history.append("idle")
	elif can_double_jump and allow_double_jump:
		can_double_jump = false
		$JumpSound.pitch_scale = 1.5
	else:
		return
	velocity.y = jump_speed
	$JumpSound.play()

func _on_switch(_from: Actor):
	$SwitchEffect.emitting = true

func _on_death_effect_finished() -> void:
	on_death.emit(self)
