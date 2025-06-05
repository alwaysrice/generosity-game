class_name Game extends Node2D

@onready var level = %Level
@export_file("*.tscn") var initial_level

func _ready() -> void:
	if initial_level:
		level.add_child(GameManager.load_level(initial_level))

func _input(event: InputEvent) -> void:
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
			%PauseMenu.open()
		else:
			%PauseMenu.close()
		get_tree().root.set_input_as_handled()
		
	elif event.is_action_pressed("debug_2"):
		if $CanvasLayer.get_child_count() <= 1:
			var level = $Level.get_child(0) as Level
			level.fade_music_to_stop(1.0, func():
				get_tree().paused = true
				)
			var contellation: Constellation = load("res://scripts/puzzle/big_dipper.tscn").instantiate()
			$CanvasLayer.add_child(contellation)
			contellation.starts_fading.connect(func():
				get_tree().paused = false
				level.face_music_resume(1.0)
				, CONNECT_ONE_SHOT)
		else:
			var constel = $CanvasLayer.get_child(1)
			$CanvasLayer.remove_child(constel)
			constel.queue_free()
			get_tree().paused = false
			
