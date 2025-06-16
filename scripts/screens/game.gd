class_name Game extends Node2D

@onready var level = %Level
@export_file("*.tscn") var initial_level
@export_dir var levels_dir: String


func get_levels_to_load(folder_path: String):
	var dir := DirAccess.open(folder_path)
	var array = []
	if dir == null:
		print("Failed to open directory: ", folder_path)
		return

	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".tscn") and file_name != "level.tscn":
			var file_path = folder_path + "/" + file_name
			array.append(file_path)

	dir.list_dir_end()
	return array

func _ready() -> void:
	GameManager.load_dialogues("res://audio/dialogue set 1")
	for level in get_levels_to_load(levels_dir):
		GameManager.load_level_async(level)
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
			
