extends Level


func _ready() -> void:
	%Witch.turn_left()
	%Cat.turn_left()
	if not is_once: return
	super._ready()
	%Music.play()
	%Music2.play()
	%Music3.play()
