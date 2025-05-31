extends Node2D
var start_point := Vector2.ZERO
var end_point := Vector2(200, 0)

func _process(delta):
		# Example: Animate end point over time (for demo purposes)
	end_point = Vector2(200 + sin(Time.get_ticks_msec() / 500.0) * 100, 0)
	queue_redraw()

func _draw():
	var base_color := Color(1, 1.0, 1)
	var steps := 3
	var max_thickness := 20.0

	# Glow layers
	for i in range(steps):
		var t = float(i) / steps
		var width = lerp(max_thickness, 2.0, t)
		var alpha = lerp(0.05, 0.2, 1.0 - t)
		var glow_color := Color(base_color.r, base_color.g, base_color.b, alpha)
		draw_line(start_point, end_point, glow_color, width, true)

	# Solid core line
	draw_line(start_point, end_point, Color(base_color.r, base_color.g, base_color.b, 1.0), 2, true)
