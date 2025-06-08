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
	
func upgrade_witch():
	for level in level_history.values():
		level.get_nyota().upgrade_fly_duration()
	
