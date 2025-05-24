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

@export var following: Actor
@export var should_follow = false

@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var graphics := $Graphics as Node2D

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
var can_double_jump := false
var should_jump := false
var is_jumping := false
var is_flying := false
var is_dead := false
var is_player := false
var last_direction = 0
var spawn_point = Vector2.ZERO
var items = []
var action_history = []

signal on_death(actor: Actor)

func revive():
	is_dead = false
	graphics.modulate = Color.WHITE
	position = spawn_point
	spawn_point = Vector2.ZERO

func die(pos: Vector2):
	spawn_point = pos
	$DeathEffect.emitting = true
	graphics.modulate = Color.TRANSPARENT
	is_dead = true

func afk_behaviour(delta: float):
	if not following or not should_follow: return
	var dist = following.global_position - global_position
	var speed = walk_speed
	var accel = walk_accel
	if dist.x > follow_distance_run || dist.x < -follow_distance_run:
		speed = run_speed	
		accel = run_accel
	
	if is_jumping:
		velocity.x = move_toward(velocity.x, sign(velocity.x) * speed, accel * speed * delta)
	elif dist.x > follow_distance || dist.x < -follow_distance:
		velocity.x = move_toward(velocity.x, sign(dist.x) * speed, accel * speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, accel * speed * delta)
	if $CliffDetector.is_colliding():
		try_jump()
	
func turn_left():
	velocity.x = 0
	graphics.scale.x = -1
	
func turn_right():
	velocity.x = 0
	graphics.scale.x = 1
	
func _unhandled_input(event):
	if event.is_action_pressed("move_right"):
		last_direction = 1
	elif event.is_action_pressed("move_left"):
		last_direction = -1
		
func get_input_direction():
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
		
	if is_player and (Input.is_action_just_pressed("jump") or should_jump):
		try_jump()
	if not is_flying:
		velocity.y = minf(fall_speed_max, velocity.y + gravity * delta)
	
	if is_player:
		var speed = walk_speed
		var accel = walk_accel
		if Input.is_action_pressed("run"):
			speed = run_speed
			accel = run_accel
	
		var direction: float = get_input_direction() * speed * int(is_player)
		velocity.x = move_toward(velocity.x, direction, accel * speed * delta)
	else:
		afk_behaviour(delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			graphics.scale.x = 1.0
		else:
			graphics.scale.x = -1.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()
	
	var animation := get_new_animation()
	var graphics = $Graphics.get_child(0)
	if graphics is AnimatedSprite2D and graphics.animation != animation:
		graphics.play(animation)
		

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
		is_jumping = false
	else:
		if is_flying:
			animation_new = "fly"
		elif velocity.y > 0.0:
			animation_new = "fall"
		else:
			animation_new = "jump"
			
	if Input.is_action_pressed("run") and animation_new == "walk":
		animation_new = "run"
	return animation_new


func try_jump() -> void:
	if is_dead: return
	if is_on_floor():
		$JumpSound.pitch_scale = 1.0
		is_jumping = true
	elif can_double_jump:
		can_double_jump = false
		$JumpSound.pitch_scale = 1.5
	else:
		return
	velocity.y = jump_speed
	$JumpSound.play()

func _on_switch(from: Actor):
	$SwitchEffect.emitting = true

func _on_death_effect_finished() -> void:
	on_death.emit(self)
