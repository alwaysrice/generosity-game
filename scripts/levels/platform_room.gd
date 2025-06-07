extends Level


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
		constellation.finished_success.connect(func():
			contel_finished += 1
			, CONNECT_ONE_SHOT)
		fade_music_to_stop(1.0, func():
			get_tree().paused = true
			)
		constellation.show() 
		constellation.process_mode = Node.PROCESS_MODE_ALWAYS
		constellation.animator.play("constellation/enter")
		constellation.starts_fading.connect(func():
			get_tree().paused = false
			face_music_resume(1.0)
			, CONNECT_ONE_SHOT)
