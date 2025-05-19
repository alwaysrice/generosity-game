class_name Actor extends CharacterBody2D

@export var walk_speed = 100.0
@export var accel_speed = 100 * 6.0
@export var jump_speed = -725.0
@export var fall_speed_max = 700
@export var follow_distance = 100
var is_player := false
@export var following: Actor

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var graphics := $Graphics as Node2D
var can_double_jump := false
var should_jump := false
var is_jumping = false

var action_history = []

func afk_behaviour(delta: float):
	var dist = following.global_position - global_position
	if is_jumping:
		velocity.x = move_toward(velocity.x, sign(velocity.x) * walk_speed, accel_speed * delta)
	elif dist.x > follow_distance || dist.x < -follow_distance:
		velocity.x = move_toward(velocity.x, sign(dist.x) * walk_speed, accel_speed * delta)
		if $CliffDetector.is_colliding():
			try_jump()
	else:
		velocity.x = move_toward(velocity.x, 0, accel_speed * delta)
	

func _physics_process(delta: float) -> void:
	if is_on_floor():
		can_double_jump = true
		
	if is_player and (Input.is_action_just_pressed("jump") or should_jump):
		try_jump()
	velocity.y = minf(fall_speed_max, velocity.y + gravity * delta)
	
	if is_player:
		var direction: float = Input.get_axis("move_left", "move_right") * walk_speed * int(is_player)
		velocity.x = move_toward(velocity.x, direction, accel_speed * delta)
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
		if absf(velocity.x) > 0.1:
			animation_new = "walk"
		else:
			animation_new = "idle"
		is_jumping = false
	else:
		if velocity.y > 0.0:
			animation_new = "fall"
		else:
			animation_new = "jump"
	return animation_new


func try_jump() -> void:
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
