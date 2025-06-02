class_name Witch extends Actor

var can_fly = true
var is_on_flight = false
@onready var broom: Area2D = %Broom
@export var fly_jump_speed = -80.0
@export var vertical_speed = 300.0
@export var vertical_accel = 6
@export var fly_collision_offset = 26

signal done_flying

func upgrade_fly_duration():
	%FlightTimer.wait_time += 1.0

func turn_right():
	super.turn_right()
	if not is_follow_object() and following.has_joined_other:
		var cat = following as Cat
		cat.global_position.x = %Broom/Dest.global_position.x

func turn_left():
	super.turn_left()
	if not is_follow_object() and following.has_joined_other:
		var cat = following as Cat
		cat.global_position.x = %Broom/Dest.global_position.x


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
		
	if event.is_action_pressed("fly") and can_fly and not is_flying:
		is_flying = true
		can_fly = false
		global_position -= %FlyOffset.position
		($CollisionShape2D.shape as CapsuleShape2D).height -= fly_collision_offset
		velocity.y = fly_jump_speed
		$FlyTimer.start()
		prevent_movement = true
		
		if following is Cat:
			following.join_fly()
		
		var sprite = $Graphics.get_child(0)
		if sprite is AnimatedSprite2D:
			sprite.play(&"fly")
			
func _on_flight_timer_timeout() -> void:
	is_flying = false
	is_on_flight = false
	($CollisionShape2D.shape as CapsuleShape2D).height += fly_collision_offset

	done_flying.emit()
	print("done")


func _on_fly_timer_timeout() -> void:
	$FlightTimer.start()
	velocity.y = 0
	prevent_movement = false
	
	is_on_flight = true
	var sprite = $Graphics.get_child(0)
	if sprite is AnimatedSprite2D:
		sprite.play(&"flight")
	
