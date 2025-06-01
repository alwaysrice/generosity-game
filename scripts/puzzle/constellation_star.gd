class_name ConstellationStar extends Node2D

@export var next: Array[Node] = []
@export var ender = false

func can_end_in_next():
	for i in next:
		if i.ender:
			return true
	return false

func unactivate():
	$Unactivated.visible = false
	$Activated.visible = false
	unhint_next()
	


func activate():
	$Unactivated.visible = false
	$Activated.visible = true
	$AnimationPlayer.play("activate")
	hint_next()
	
func hint_next():
	for i in next:
		if i.get_node("Activated").visible:
			continue
		i.get_node("AnimationPlayer").play("hint")
		i.get_node("Unactivated").visible = true
		i.get_node("Activated").visible = false

func unhint_next():
	for i in next:
		i.get_node("Unactivated").visible = false
