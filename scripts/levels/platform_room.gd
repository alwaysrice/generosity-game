extends Level


func _ready() -> void:
	%Witch.turn_left()
	%Cat.turn_left()
	if not is_once: return
	super._ready()
