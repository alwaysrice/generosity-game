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
	
	var spawn = %SpawnTop if is_switched else %SpawnBottom
	%Witch.global_position.y = spawn.global_position.y
	%Cat.global_position.y = spawn.global_position.y


func _ready() -> void:
	if not is_once: return
	super._ready()
	apply_switch()
	%LanternBottom.has_lighted.connect(toggle_switch)
	%LanternTop.has_lighted.connect(toggle_switch)
	for child in $Graphics/Variant1.get_children():
		if child is LevelConnectBoundary:
			child.body_entered.connect(func(body: Node2D): _on_enter_level_boundary(child))
	for child in $Graphics/Variant2.get_children():
		if child is LevelConnectBoundary:
			child.body_entered.connect(func(body: Node2D): _on_enter_level_boundary(child))
