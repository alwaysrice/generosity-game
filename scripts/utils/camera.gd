class_name Camera extends Camera2D

@export var target: Node2D
@export var offset_target = Vector2.ZERO

func set_target(path: NodePath):
	target = get_node(path)

func _physics_process(_delta: float) -> void:
	if (target != null): 
		position = target.position + offset_target
