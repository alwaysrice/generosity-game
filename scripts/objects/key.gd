class_name Key extends Area2D

var holder: Actor
func _on_body_entered(body: Node2D) -> void:
	if holder and self in holder.items: 
		return
		
	assert(body is Actor)
	var actor = body as Actor	
	actor.items.append(self) 
	holder = actor
	$CollectEffect.emitting = true
	$Graphics.visible = false
