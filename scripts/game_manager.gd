extends Node

var level_history = {}

func load_level(file: String) -> Level:
	if file in level_history:
		return level_history[file]
	var new_level = load(file).instantiate()
	print("loaded new level: " + type_string(typeof(new_level)))
	level_history[file] = new_level
	return new_level
