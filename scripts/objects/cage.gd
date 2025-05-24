class_name Cage extends Node2D
 
@export var radius: float = 64.0


func destruct():
	get_parent().remove_child(self)
	queue_free()

func unlock():
	$AnimationPlayer.play(&"unlock")


func _on_key_detect_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		for i in body.items:
			if i is Key:
				i.use()
				
