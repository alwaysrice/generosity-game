class_name Hallway4 extends Level

@export_file("*.tscn") var corridor_path: String

var can_play_last_scene = false

func trigger_corridor_event():
	var corridor = GameManager.level_history[corridor_path] as Corridor
	corridor.can_play_scene = true
	print("Triggered corridor event")
	

func _ready() -> void:
	if can_play_last_scene:
		print("Starting hallway scene")
		can_play_last_scene = false
		$Cutscenes.animation_finished.connect(func(anim: StringName):
			$Cutscenes.play("story/last")
			$Cutscenes.animation_finished.connect(func(anim):
				print("Finished hallway last scene")
				, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)

	if not is_once: return
	super._ready()
