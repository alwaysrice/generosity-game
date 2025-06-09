extends Node

var level_history = {}
var dialogues: Array[AudioStream] = []
var dialogue_counter = -1

func load_level(file: String) -> Level:
	if file in level_history:
		print("Fetched exiting level")
		return level_history[file]
	else:
		print("Loading new level")
	var new_level = load(file).instantiate()
	level_history[file] = new_level
	return new_level
	
func upgrade_witch():
	for level in level_history.values():
		level.get_nyota().upgrade_fly_duration()
	
func load_dialogues(folder_path: String):
	var dir := DirAccess.open(folder_path)
	if dir == null:
		print("Failed to open directory: ", folder_path)
		return

	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".mp3"):
			var file_path = folder_path + "/" + file_name
			var stream: AudioStream = load(file_path)
			if stream != null:
				dialogues.append(stream)
				print("Loaded: ", file_path)
			else:
				print("Failed to load: ", file_path)
				dialogues.clear()
				return

	dir.list_dir_end()

func push_dialogue() -> AudioStream:
	dialogue_counter += 1
	if dialogue_counter < dialogues.size():
		return dialogues[dialogue_counter]
	return null
