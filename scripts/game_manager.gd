extends Node

var level_history = {}
var level_in_progress = []
var dialogues: Array[AudioStream] = []
var dialogue_counter = -1

func load_level(file: String) -> Level:
	# Block thread and wait 
	if file in level_in_progress:
		print("Waiting for asynchronous loaded level ", file)
		level_history[file] = ResourceLoader.load_threaded_get(file).instantiate()
		
	# Already loaded
	if file in level_history:
		print("Fetched existing level ", file)
		return level_history[file]
	else:
		print("Loading new level ", file)
	var new_level = load(file).instantiate()
	level_history[file] = new_level
	return new_level
	
func load_level_async(file: String):
	var new_level = ResourceLoader.load_threaded_request(file)
	level_in_progress.append(file)
	
func _process(delta: float) -> void:
	var remove_list = []
	for level in level_in_progress:
		if ResourceLoader.load_threaded_get_status(level) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var loaded_level = ResourceLoader.load_threaded_get(level).instantiate()
			var uid = "uid://" + str(ResourceLoader.get_resource_uid(level))
			level_history[uid] = loaded_level
			remove_list.append(level)
			print("Finished loading asynchronous level ", uid)

	for i in remove_list:
		level_in_progress.erase(i)
	
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
