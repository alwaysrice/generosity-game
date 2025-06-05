class_name Constellation extends Node2D

@export var point_radius = 20.0
@export var magnet_radius = 100.0
@export var allow_magnet = false
@export var line_width = 4.0
@export var star_gap = 40.0
@export var start: ConstellationStar
@export var line_color = Color.WHITE
@export var glow_gradient: Gradient
@export var glow_color_width = 1
@export var chimes: Array[AudioStream] = []
var has_connected_all = false
var is_dragging := false
var connected_points: Array[ConstellationStar] = []
signal connected_all
signal connect_point(point: Node2D)
signal released_connection

func get_connected_points_pos():
	var connected_points_pos = []
	for point in connected_points: 
		connected_points_pos.append(point.global_position)
	return connected_points
	
func can_start():
	return $MouseLine.visible
	
func enter():
	$MouseLine.visible = true
	has_connected_all = false
	for star: ConstellationStar in %Stars.get_children():
		star.unactivate()
	connected_points.append(start)
	start.activate()
	$Melody.clear_playlist()
	$Melody.add_music(chimes[connected_points.size()-1])
	$Melody.play_next()
	%MouseLine.set_point_position(0, Vector2.ZERO)
	%MouseLine.set_point_position(1, Vector2.ZERO)
	
func _ready() -> void:
	assert(%Stars.get_children().size() > 1)
	for star: ConstellationStar in %Stars.get_children():
		star.unactivate()

func _input(event: InputEvent) -> void:
	if has_connected_all: return
	if event is InputEventMouseButton and can_start():
		if event.button_index == MOUSE_BUTTON_LEFT:
			queue_redraw()
			if event.pressed:
				has_connected_all = false
				#if check_for_point():
				is_dragging = true
				var gapped_pos = get_gapped_line(start.global_position, start.global_position, star_gap)[1]

				%MouseLine.set_point_position(0, gapped_pos)

			else:
				is_dragging = false 
				connected_points.clear()
				enter()
				var removal_list = %Lines.get_children()
				for i in removal_list:
					%Lines.remove_child(i)
					i.queue_free()



func get_gapped_line(start: Vector2, end: Vector2, gap: float) -> PackedVector2Array:
	var direction = (end - start).normalized()
	var offset = direction * (gap / 2.0)

	var new_start = start + offset
	var new_end = end - offset
	
	return PackedVector2Array([new_start, new_end])
			
func check_for_point() -> bool:
	var mouse_pos = get_global_mouse_position()
	var points = %Stars.get_children()
	for point: ConstellationStar in points:
		var last_point: ConstellationStar = connected_points.back()
		assert(last_point)
		var ender = connected_points.size() == points.size() and point.ender 
		if ender:
			pass
		elif point in connected_points or point not in last_point.next: 
			continue
		var radius = point_radius
		if allow_magnet:
			radius += magnet_radius
		if Geometry2D.is_point_in_circle(mouse_pos, point.global_position, radius):
			connected_points.append(point)		
			last_point.unhint_next()
			point.activate()
			
			for i in range(glow_gradient.colors.size()-1, -1, -1):
				var line = Line2D.new()
				var glow_width = i * glow_color_width
				var color = glow_gradient.get_color(i)
				line.joint_mode = Line2D.LINE_JOINT_ROUND
				line.begin_cap_mode = Line2D.LINE_CAP_ROUND
				line.end_cap_mode = Line2D.LINE_CAP_ROUND
				line.default_color = color
				line.width = line_width + glow_width 
				line.points = get_gapped_line(last_point.global_position, point.global_position, star_gap)			
				%Lines.add_child(line)
				%MouseLine.set_point_position(0, point.global_position)
			
			connect_point.emit(point)
			
			if (connected_points.size() == points.size() and not point.can_end_in_next()) \
			or (point.ender and connected_points.size() >= points.size()):
				connected_all.emit()
				has_connected_all = true
			else:
				$Melody.add_music(chimes[connected_points.size()-1])

			return true
	return false

func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		%MouseLine.set_point_position(1, mouse_pos)
		check_for_point()
		#queue_redraw()
	if has_connected_all:
		queue_redraw()
		
func end():
	$MouseLine.visible = false
	$Melody.clear_playlist()
	connected_points.clear()
	var removal_list = %Lines.get_children()
	for i in removal_list:
		%Lines.remove_child(i)
		i.queue_free()
		
func _on_connected_all() -> void:
	is_dragging = false
	$AnimationPlayer.play("constellation/success")
