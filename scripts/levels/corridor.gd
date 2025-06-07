class_name Corridor extends Level

var is_switched = true
@export var can_play_scene = false
var can_switch = false

func allow_switching():
	can_switch = true

func toggle_process_mode(node: Node, value: bool):
	if value:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED

func toggle_switch():
	if can_switch:
		$AnimationPlayer.play("corridor/switch")
	
func apply_switch():
	is_switched = not is_switched
 
	toggle_process_mode(%Variant1, not is_switched)
	toggle_process_mode(%Variant2, is_switched)
		
	%Variant1.visible = not is_switched
	%Variant2.visible = is_switched
	
	_spawn_closest_boundary(true)
	print("Switched")

func _ready() -> void:
	if can_play_scene:
		print("Starting corridor scene")
		can_play_scene = false
		$Cutscenes.animation_finished.connect(func(anim: StringName):
			$Cutscenes.play("story/scene")
			$Cutscenes.animation_finished.connect(func(anim):
				print("Finished corridor scene")
				, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)

	if not is_once: return
	apply_switch()
	super._ready()
	%LanternBottom.has_lighted.connect(toggle_switch)
	%LanternTop.has_lighted.connect(toggle_switch)

	
func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if event.is_action_pressed("spellcast") and can_switch:
		if %LanternBottom.can_activate:
			%Witch.spellcast()
			%LanternBottom.toggle_activation()
		if %LanternTop.can_activate:
			%LanternTop.toggle_activation()
			%Witch.spellcast()


func _on_entered_level():
	print("ENTEREd: can play: " + str(can_play_scene))
	if can_play_scene:
		can_play_scene = false
		$Cutscenes.play("story/scene")
		$Cutscenes.animation_finished.connect(func(anim):
			print("finished all animation")
			, CONNECT_ONE_SHOT)
	
	
func _connect_boundaries():
	for child in $Graphics/Variant1.get_children():
		if child is LevelConnectBoundary:
			child.body_entered.connect(func(body: Node2D): _on_enter_level_boundary(child), CONNECT_ONE_SHOT)
	for child in $Graphics/Variant2.get_children():
		if child is LevelConnectBoundary:
			child.body_entered.connect(func(body: Node2D): _on_enter_level_boundary(child), CONNECT_ONE_SHOT)


func spawn_closest_boundary():
	_spawn_closest_boundary()

func _spawn_closest_boundary(y_only = false):
	var right: Marker2D
	var right2: Marker2D
	var left: Marker2D
	var left2: Marker2D
	if not is_switched:
		right = %Variant1.get_node("SpawnRight")
		right2 = %Variant1.get_node("SpawnRight2")
		left = %Variant1.get_node("SpawnLeft")
		left2 = %Variant1.get_node("SpawnLeft2")
	else:
		right = %Variant2.get_node("SpawnRight")
		right2 = %Variant2.get_node("SpawnRight2")
		left = %Variant2.get_node("SpawnLeft")
		left2 = %Variant2.get_node("SpawnLeft2")
	
	var spawn: Marker2D
	var spawn2: Marker2D
	
	var left_dist = absf(%Witch.global_position.x - left.global_position.x)
	var right_dist = absf(%Witch.global_position.x - right.global_position.x)
	if left_dist < right_dist: 
		spawn = left
		spawn2 = left2
		%Witch.turn_right()
		%Cat.turn_right()
	else:
		spawn = right
		spawn2 = right2
		%Witch.turn_left()
		%Cat.turn_left()
	
	if y_only:
		%Witch.global_position.y = spawn.global_position.y
		%Cat.global_position.y = spawn.global_position.y
	else:
		%Witch.global_position = spawn.global_position
		%Cat.global_position = spawn.global_position	
	%Witch.stop()
	%Cat.stop()
