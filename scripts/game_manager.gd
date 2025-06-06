extends Node

var level_history = {}

func load_level(file: String) -> Level:
	if file in level_history:
		print("Fetched exiting level")
		return level_history[file]
	else:
		print("Loading new level")
	var new_level = load(file).instantiate()
	level_history[file] = new_level
	return new_level
	
	
