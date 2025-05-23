extends Node2D

@export var camera: Camera2D

func get_bounds() -> Rect2:
	var rect = Rect2(10000, 10000, 0, 0)
	var get_tilemap_bounds = func(t, r):
		for layer in t.get_layers_count():
			for i in t.get_used_cells(layer):
				i *= t.tile_set.tile_size
				r.position.x = min(i.x, r.position.x)
				r.position.y = min(i.y, r.position.y)
				r.size.x = max(i.x, r.size.x)
				r.size.y = max(i.y, r.size.y)
		return r
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
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y 
	camera.limit_right = bounds.size.x
	camera.limit_bottom = bounds.size.y 


func _on_key_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
