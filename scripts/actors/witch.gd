class_name Witch extends Actor

var can_fly = true

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor():
		can_fly = true
		
	if not is_flying:
		return

func _input(event: InputEvent) -> void:
	if not is_player:
		return
		
	if event.is_action_pressed("fly") and can_fly and not is_flying:
		is_flying = true
		can_fly = false
		velocity.y = jump_speed
		$FlyTimer.start()


func _on_flight_timer_timeout() -> void:
	is_flying = false


func _on_fly_timer_timeout() -> void:
	$FlightTimer.start()
	velocity.y = 0
