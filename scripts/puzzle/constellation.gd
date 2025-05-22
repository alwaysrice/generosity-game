class_name Constellation extends Node2D

@export var point_radius = 100
@export var magnet_radius = 100
@export var allow_magnet = false
@export var line_width = 10
var has_connected_all = false
var is_dragging := false
var connected_points = []
signal connected_all
signal connect_point(point: Node2D)
signal released_connection

func get_connected_points_pos():
	var connected_points_pos = []
	for point in connected_points: 
		connected_points_pos.append(point.global_position)
	return connected_points

func _draw() -> void:
	var loop_draw = func():
		var points = get_connected_points_pos()
		for i in range(points.size() - 1):
			draw_line(points[i].global_position, points[i + 1].global_position, Color.WHITE, line_width)
	if is_dragging:
		loop_draw.call()
		draw_line(connected_points.back().global_position, get_global_mouse_position(), Color.WHITE, line_width)
	if has_connected_all:
		loop_draw.call()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			queue_redraw()
			if event.pressed:
				connected_points.clear()
				has_connected_all = false
				if check_for_point():
					is_dragging = true
			else:
				is_dragging = false 

			
func check_for_point() -> bool:
	var mouse_pos = get_global_mouse_position()
	var points = get_children()
	for point: Node2D in points:
		if point in connected_points: 
			continue
		var radius = point_radius
		if allow_magnet:
			radius += magnet_radius
		if Geometry2D.is_point_in_circle(mouse_pos, point.global_position, radius):
			connected_points.append(point)
			connect_point.emit(point)
			if connected_points.size() == points.size():
				connected_all.emit()
				has_connected_all = true
			return true
	return false

func _process(delta: float) -> void:
	if is_dragging:
		check_for_point()
		queue_redraw()
	if has_connected_all:
		queue_redraw()

func _on_connected_all() -> void:
	is_dragging = false
