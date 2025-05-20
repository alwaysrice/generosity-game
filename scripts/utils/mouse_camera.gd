extends Camera
class_name DraggableCamera

signal changed_zoom(zoom: Vector2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= Vector2(0.05, 0.05)
			changed_zoom.emit(zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(0.05, 0.05)
			changed_zoom.emit(zoom)
			
