class_name Door extends Node2D

@export_file("*.tscn") var destination: String
@export var target: Node2D
@export var decline_rotation = 160.0
## How far the eyeball can move from center
@export var max_offset: float = 10.0 
@export var follow_strength: float = 1.0 
@export var open_eyes_on_first_target = false
signal within_range_solo
signal within_range
signal wants_to_enter

var is_within_range = false
var region_orig_rect
func _ready() -> void:
	region_orig_rect = %Eyeball.region_rect
	if open_eyes_on_first_target:
		open_eye()

func open_eye():
	%"Eye(closed)".visible = false
	%"Eye(open)".visible = true

func _process(_delta: float) -> void:	
	if destination and is_within_range and Input.is_action_just_pressed("enter_door"):
		print("WANTs TO ENTEr")
		wants_to_enter.emit()
	
	if not target: 
		return
		
	var eyeball: Sprite2D = %Eyeball
	#eyeball.rotation = eyeball.global_position.angle_to_point(target.global_position) 
	#eyeball.rotation_degrees -= decline_rotation

	var to_target = target.global_position - eyeball.global_position
	# Get direction from this sprite (eyeball) to target (player)
	var distance = to_target.length()
	if distance == 0:
		return
	var offset = to_target.normalized() * min(distance * follow_strength, max_offset)
	var texture_size = eyeball.texture.get_size()
	
	# Adjust region_rect's position so that the pupil visually moves
	var new_region_pos = -offset.round() 
	#eyeball.region_rect.position = new_region_pos
	#eyeball.region_rect.size = region_orig_rect.size + offset
	eyeball.position = offset * scale

func _on_enter_area_body_entered(body: Node2D) -> void:
	if body is Witch:
		$AnimationPlayer.play("within_range")
		within_range.emit()
		is_within_range = true
		
	elif not body.following or body.following is not Actor or body.following.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		within_range_solo.emit()


func _on_enter_area_body_exited(_body: Node2D) -> void:
	$AnimationPlayer.play("not_within_range")
	is_within_range = false
