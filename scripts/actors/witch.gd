class_name Witch extends Actor

var can_fly = true
var is_on_flight = false
@export var vertical_speed = 300.0
@export var vertical_accel = 6

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor():
		can_fly = true
		
	if is_on_flight:
		var direction = Input.get_axis("move_up", "move_down") * vertical_speed
		velocity.y = move_toward(velocity.y, direction, vertical_accel * vertical_speed * delta)


func _input(event: InputEvent) -> void:
	if not is_player:
		return
		
	if event.is_action_pressed("fly") and can_fly and not is_flying:
		is_flying = true
		can_fly = false
		velocity.y = jump_speed
		$FlyTimer.start()
		var sprite = $Graphics.get_child(0)
		if sprite is AnimatedSprite2D:
			sprite.play(&"fly")
			
func _on_flight_timer_timeout() -> void:
	is_flying = false
	is_on_flight = false


func _on_fly_timer_timeout() -> void:
	$FlightTimer.start()
	velocity.y = 0
	is_on_flight = true
	var sprite = $Graphics.get_child(0)
	if sprite is AnimatedSprite2D:
		sprite.play(&"flight")
	
