class_name Key extends Area2D


func _on_body_entered(body: Node2D) -> void:
	assert(body is Actor)
	var actor = body as Actor
	actor.items.append(self) 
	visible = false
