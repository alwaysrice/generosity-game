class_name Barrier extends Area2D

signal wants_to_interact
var can_cast = false
@export var constellation: Constellation

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spellcast") and can_cast:
		wants_to_interact.emit()

func _on_body_entered(body: Node2D) -> void:
	can_cast = true


func _on_body_exited(body: Node2D) -> void:
	can_cast = false
