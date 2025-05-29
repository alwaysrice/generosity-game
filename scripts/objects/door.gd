class_name Door extends Node2D

@export var target: Node2D
@export var decline_rotation = 160.0
## How far the eyeball can move from center
@export var max_offset: float = 10.0 
@export var follow_strength: float = 1.0 
signal within_range

func open_eye():
	%"Eye(closed)".visible = false
	%"Eye(open)".visible = true


func _process(_delta: float) -> void:	
	if not target: 
		return
		
	var eyeball = %Eyeball
	#eyeball.rotation = eyeball.global_position.angle_to_point(target.global_position) 
	#eyeball.rotation_degrees -= decline_rotation

	var to_target = target.global_position - eyeball.global_position
	var offset = to_target.normalized() * min(to_target.length() * follow_strength, max_offset)
	eyeball.position = offset


func _on_enter_area_body_entered(body: Node2D) -> void:
	if body is Witch:
		$AnimationPlayer.play("within_range")
		within_range.emit()


func _on_enter_area_body_exited(_body: Node2D) -> void:
	$AnimationPlayer.play("not_within_range")
