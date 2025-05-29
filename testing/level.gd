extends Node2D

var counter = 0
func _process(delta: float) -> void:
	print(counter)
	counter += 1
	if Input.is_action_pressed("enter_game"):
		print("LOAD")
		get_tree().change_scene_to_file("res://scripts/screens/game.tscn")
		print("LOAD 2")
