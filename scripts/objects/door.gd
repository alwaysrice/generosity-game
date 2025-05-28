class_name Door extends Node2D

@export var target: Node2D
@export var decline_rotation = 160

func open_eye():
	%"Eye(closed)".visible = false
	%"Eye(open)".visible = true


func _process(_delta: float) -> void:	
	if not target: 
		return

	%Eyeball.rotation = %Eyeball.global_position.angle_to_point(target.global_position) 
	%Eyeball.rotation_degrees -= decline_rotation
