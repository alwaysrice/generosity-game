extends Level

@export_file("*.tscn") var corridor_path: String

func trigger_corridor_event():
	var corridor = GameManager.level_history[corridor_path] as Corridor
	corridor.can_play_scene = true
	print("TRIGGERED EVENT")
	
