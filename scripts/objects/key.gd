class_name Key extends Area2D

class UseErrand extends Errand:
	var actor: Actor
	var item: Key
	func is_done() -> bool:
		return item.is_done_using()
		
class HasKeyErrand extends Errand:
	var actor: Actor
	func is_done() -> bool:
		for item in actor.items:
			if item is Key:
				return true
		return false

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
	$CollectSFX.play()
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
