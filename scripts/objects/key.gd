class_name Key extends Area2D

@export var cage: Cage
var holder: Actor
var dead = false

func _on_body_entered(body: Node2D) -> void:
	if (holder and self in holder.items) or dead: 
		return
		
	assert(body is Actor)
	var actor = body as Actor	
	actor.items.append(self) 
	holder = actor
	$CollectEffect.emitting = true
	$Graphics.visible = false


func use():
	cage.unlock()
	cage = null
	holder.items.erase(self)
	holder = null
	dead = true
	
func is_done_using() -> bool:
	return true
