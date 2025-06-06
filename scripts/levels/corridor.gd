extends Level

var is_switched = true

func toggle_process_mode(node: Node, value: bool):
	if value:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED

func toggle_switch():
	$Cutscenes.play("corridor/switch")
	
func apply_switch():
	is_switched = not is_switched

	toggle_process_mode(%Variant1, not is_switched)
	toggle_process_mode(%Variant2, is_switched)
		
	%Variant1.visible = not is_switched
	%Variant2.visible = is_switched
	
	_spawn_closest_boundary(true)

func _ready() -> void:
	if not is_once: return
	apply_switch()
	super._ready()
	%LanternBottom.has_lighted.connect(toggle_switch)
	%LanternTop.has_lighted.connect(toggle_switch)
	
	
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
