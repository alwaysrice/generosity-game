class_name Witch extends Actor

var can_fly = true
var is_on_flight = false
@onready var broom: Area2D = %Broom
@export var fly_jump_speed = -30.0
@export var vertical_speed = 300.0
@export var vertical_accel = 6
@export var fly_collision_offset = 26
var finished_fly = false
var is_success_fly_with_other = false
signal hint_fly_interruped
signal successful_fly_with_other
var fly_sfx_dur = 1.0


signal done_flying

func upgrade_fly_duration():
	%FlightTimer.wait_time += 2.0

func turn_right():
	super.turn_right()
	if following is Cat and following.has_joined_other:
		var cat = following as Cat
		cat.global_position.x = %Broom/Dest.global_position.x

func turn_left():
	super.turn_left()
	if following is Cat and following.has_joined_other:
		var cat = following as Cat
		cat.global_position.x = %Broom/Dest.global_position.x


func start_flight():
	$FlightTimer.start()
	$MaxWaitTimer.stop()
	prevent_movement = false
	is_on_flight = true
	var sprite = $Graphics.get_child(0)
	if sprite is AnimatedSprite2D:
		sprite.play(&"flight")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor():
		can_fly = true
		
	if is_on_flight and not prevent_movement:
		var direction = Input.get_axis("move_up", "move_down") * vertical_speed
		velocity.y = move_toward(velocity.y, direction, vertical_accel * vertical_speed * delta)


func _unhandled_input(event: InputEvent) -> void:
	if not is_player:
		return
		
	if is_flying and $SFXTimer.time_left == 0.0:
		$SFXTimer.start(fly_sfx_dur)
		print("Playing flying sfx")
		$FlySFX.play()
		
	if event.is_action_pressed("fly") and can_fly and not is_flying and not is_jumping:
		is_flying = true
		can_fly = false
		global_position -= %FlyOffset.position
		($CollisionShape2D.shape as CapsuleShape2D).height -= fly_collision_offset
		velocity.y = fly_jump_speed
		$FlyTimer.start()
		prevent_movement = true
				
		var sprite = $Graphics.get_child(0)
		if sprite is AnimatedSprite2D:
			sprite.play(&"fly")
			
		# If there is a cat following, wait for him
		if following is Cat and following.following is Witch:
			following.join_fly()
			following.has_joined.connect(start_flight, CONNECT_ONE_SHOT)
	if event.is_action_pressed("pet") and following is Cat and following.following is Witch and get_sprite().animation == "idle" and not is_petting:
		pet()
		
var is_petting = false
func pet():
	var cat = following as Cat
	is_petting = true
	var tween = create_tween()
	tween.tween_property(cat, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(func():
		velocity.x = 0
		global_position -= %PetOffset.position
		$CollisionShape2D.global_position += %PetOffset.position
		get_sprite().play(&"pet")
		get_sprite().animation_finished.connect(func():
			global_position += %PetOffset.position
			$CollisionShape2D.global_position -= %PetOffset.position
			get_sprite().play(&"idle")
			cat.global_position = global_position
			var return_tween = create_tween()
			return_tween.tween_property(cat, "modulate", Color.WHITE, 0.3)
			return_tween.tween_callback(func():
				is_petting = false
				)
			, CONNECT_ONE_SHOT)
		)
			
func _on_flight_timer_timeout() -> void:
	$MaxWaitTimer.stop()
	is_flying = false
	is_on_flight = false
	($CollisionShape2D.shape as CapsuleShape2D).height += fly_collision_offset
	done_flying.emit()


func _on_fly_timer_timeout() -> void:
	velocity.y = 0
	finished_fly = true
	$MaxWaitTimer.start()
	# If there is NO cat following, then go on your own
	if following is not Cat:
		start_flight()
	

func _on_max_wait_timer_timeout() -> void:
	if following is Cat:
		is_success_fly_with_other = false
		hint_fly_interruped.emit()
