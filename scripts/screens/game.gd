class_name Game extends Node


@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@export var camera: Camera
@export var cat: Cat
@export var witch: Witch


func _ready() -> void:
	if not $StoryPlayer.active:
		$Level/Witch.should_follow = true
		$Level/Cat.should_follow = true
		switch_witch()
	
func switch_witch():
	switch_player(witch)
	
func switch_player(who: Actor = null) -> Actor:
	if !who:
		assert(cat.is_player != witch.is_player)
		cat.is_player = !cat.is_player
		witch.is_player = !witch.is_player
		who = witch if witch.is_player else cat
	else:
		cat.is_player = false
		witch.is_player = false
		
	camera.enabled = true
	who.is_player = true
	camera.target = who
	
	return who
		


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
		
	elif event.is_action_pressed(&"switch_character") && (not $StoryPlayer.is_playing() or not $StoryPlayer.active):
		var new_player = switch_player()
		new_player._on_switch(new_player.following)
		


func _on_camera_changed_zoom(zoom: Vector2) -> void:
	print(zoom)
	$InterfaceLayer/Label.text = str(zoom)


func _on_deadzone_body_entered(body: Node2D) -> void:
	var actor = body as Actor
	actor.die(actor.following.position)


func _on_death(actor: Actor) -> void:
	actor.revive()
