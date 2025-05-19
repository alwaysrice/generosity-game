class_name Game extends Node


@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@export var camera: Camera2D
@export var cat: Cat
@export var witch: Witch

func _ready() -> void:
	switch_player(witch)
	
func switch_player(who: Actor = null):
	camera.get_parent().remove_child(camera)
	if !who:
		assert(cat.is_player != witch.is_player)
		cat.is_player = !cat.is_player
		witch.is_player = !witch.is_player
		who = witch if witch.is_player else cat
	else:
		cat.is_player = false
		witch.is_player = false
		
	who.add_child(camera)
	who.is_player = true
	camera.reset_smoothing()
		
	var tween = create_tween()
	#tween.tween_property(camera, "global_position", who.global_position, 1.0)\
	#.set_trans(Tween.TRANS_SINE)\
	#.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_callback(func(): 
		#camera.position_smoothing_enabled = true
#
		#)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()
		
	elif event.is_action_pressed(&"switch_character"):
		switch_player()
		
