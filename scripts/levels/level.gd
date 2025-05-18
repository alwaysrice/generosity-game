extends Node2D

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
	rect.size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	rect.position = $Sprite2D.global_position
	return rect

func _ready():
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			var bounds := get_bounds()
			print(bounds)
			assert(camera)
			camera.limit_left = bounds.position.x
			camera.limit_top = bounds.position.y
			camera.limit_right = bounds.position.x  + bounds.size.x
			camera.limit_bottom = bounds.position.y +bounds.size.y
