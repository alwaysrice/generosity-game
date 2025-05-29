class_name PauseMenu extends Control


func close() -> void:
	get_tree().paused = false
	$AnimationPlayer.play("close")


func open() -> void:
	show()
	%ResumeButton.grab_focus()
	$AnimationPlayer.play("open")


func _on_resume_button_pressed() -> void:
	close()


func _on_quit_button_pressed() -> void:
	if visible:
		get_tree().quit()
