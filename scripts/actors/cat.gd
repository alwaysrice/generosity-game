class_name Cat extends Actor


signal has_joined 

func witch():
	return following as Witch

var counter = 0
func join_fly():
	is_joining = true
	var witch = following as Witch
	witch.done_flying.connect(func():
		witch.is_success_fly_with_other = true
		witch.successful_fly_with_other.emit()
		has_joined_other = false
		, CONNECT_ONE_SHOT)
			
func on_join():
	var sprite = $Graphics.get_child(0)
	if sprite is AnimatedSprite2D and sprite.animation == "fall":
		is_joining = false
		has_joined.emit()
		has_joined_other = true
		graphics.scale.x = witch().graphics.scale.x
		global_position = witch().graphics.get_node("Broom/Dest").global_position
		global_position -= %Offset.position
		stop()
		sprite.play("flight")
			
func _physics_process(delta: float):
	super._physics_process(delta)
	if $PlatformDetector.is_colliding() and is_joining and velocity.y > 0:
		on_join()
		
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
			should_run_following = true
	else:
		if is_joining:
			dist = witch().broom.get_node("Dest").global_position - global_position
			is_far = absf(dist.x) > 100
		if is_far:
			speed = run_speed	
			accel = run_accel
			should_run_following = true

		
	var follow_dist = follow_distance 
	if is_follow_object:
		follow_dist = follow_object_minimum
	
	var deadzone = 3
	if is_joining:
		if dist.x > deadzone || dist.x < -deadzone:
			velocity.x = move_toward(velocity.x, sign(dist.x) * speed, accel * speed * delta)
		else:
			try_jump()
	else:
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
