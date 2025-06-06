extends Node2D


signal has_lighted
var is_activated = false
var can_activate = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spellcast") and can_activate:
		is_activated = not is_activated
		if is_activated:
			$AnimationPlayer.play("turn_on")
		else:
			$AnimationPlayer.play("turn_off")
		has_lighted.emit()


func _on_spellcast_range_body_entered(body: Node2D) -> void:
	if body is Actor:
		can_activate = true
		$AnimationPlayer.play("within_range")


func _on_spellcast_range_body_exited(body: Node2D) -> void:
	if body is Actor:
		can_activate = false
		$AnimationPlayer.play("not_within_range")
