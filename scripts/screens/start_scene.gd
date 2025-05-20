class_name StartScene extends Node2D

@export var title: Label
var can_proceed = false
var next_scene = preload("res://scripts/screens/game.tscn")

func allow_proceed():
	can_proceed = true
	
func enter_game():
	get_tree().change_scene_to_packed(next_scene)

func _input(event: InputEvent) -> void:
	if not can_proceed: return
	if event is InputEventMouseButton or (event is InputEventKey and event.is_released()):
		$AnimationPlayer.play("enter_game")
