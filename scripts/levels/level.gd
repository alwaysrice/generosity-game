extends Node2D

@export var camera: Camera2D

func open_eye():
	for child in get_children():
		if child is Door:
			child.open_eye()

func get_bounds() -> Rect2:
	var rect = Rect2(10000, 10000, 0, 0)
	for child in get_children():
		if child is Sprite2D:
			rect.position.x = min(child.global_position.x, rect.position.x)
			rect.position.y = min(child.global_position.y, rect.position.y)
			rect.size.x = max(child.global_position.x + child.texture.get_size().x * child.scale.x, rect.size.x)
			rect.size.y = max(child.global_position.y + child.texture.get_size().y * child.scale.y, rect.size.y)
	return rect

func _ready():	
	var bounds := get_bounds()
	for child in get_children():
		if child is Key:
			child.body_entered.connect(_on_key_body_entered)
	print(bounds)
	assert(camera)
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y) 
	camera.limit_right = int(bounds.size.x)
	camera.limit_bottom = int(bounds.size.y) 
	
	if has_node("Witch"):
		$Door.target = get_node("Witch")


func _on_key_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
