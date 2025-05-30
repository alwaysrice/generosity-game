class_name Cage extends Node2D
 
class UnlockedErrand extends Errand:
	var actor: Actor
	var cage: Cage
	var has_unlocked = false
	func is_done() -> bool:
		return has_unlocked
		
@export var radius: float = 64.0
signal key_detect 

func destruct():
	get_parent().remove_child(self)
	queue_free()

func unlock():
	$AnimationPlayer.play(&"unlock")

#func toggle_collisions():
	#$StaticBody2D.check

func _on_key_detect_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		for i in body.items:
			if i is Key:
				i.use()
				key_detect.emit()
				
