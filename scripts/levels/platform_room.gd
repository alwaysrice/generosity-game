extends Level

@export_file("*.tscn") var hallway_path: String



func _ready() -> void:
	%Witch.turn_left()
	%Cat.turn_left()
	if not is_once: return
	super._ready()
	%Music.play()
	%Music2.play()
	%Music3.play()
	for child in $Graphics/Objects.get_children():
		if child is Barrier:
			child.wants_to_interact.connect(func():
				if not $Cutscenes.is_in_cutscene():
					cast_barrier(child.constellation)		
				)
		
var contel_finished = 0
func cast_barrier(constellation: Constellation):
	if not constellation.visible and not constellation.is_completely_done:
		%Witch.spellcast_continous(func():
			constellation.finished_success.connect(func():
				contel_finished += 1
				, CONNECT_ONE_SHOT)
			fade_music_to_none(1.6, func():
				get_tree().paused = true
				%Witch.get_sprite().play("idle")
				)
			constellation.show() 
			constellation.process_mode = Node.PROCESS_MODE_ALWAYS
			constellation.animator.play("constellation/enter")
			constellation.starts_fading.connect(func():
				get_tree().paused = false
				fade_music_to_normal_volume(2.0)
				, CONNECT_ONE_SHOT)
			
			)



func revert_music():
	%StarMusic.fade_to_stop(2.0, func():
		%Music.fade_to_play(2.0)
		%Music2.fade_to_play(2.0)
		%Music3.fade_to_play(2.0)
		)
		


func trigger_hallway_event():
	GameManager.upgrade_witch()
	var hallway = GameManager.level_history[hallway_path] as Hallway4
	hallway.can_play_last_scene = true
	print("Triggered hallway event")
	
