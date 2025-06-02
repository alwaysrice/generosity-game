class_name Cat extends Actor


func witch():
	return following as Witch

func _ready() -> void:
	var witch = following as Witch
	witch.done_flying.connect(func():
		has_joined_other = false
		)
	witch.broom.body_entered.connect(func(body: Node2D):
		var sprite = $Graphics.get_child(0)
		if sprite is AnimatedSprite2D and sprite.animation == "fall":
			is_joining = false
			has_joined_other = true
			stop()
			sprite.play("flight"))


func join_fly():
	is_joining = true
	global_position = witch().global_position 
	global_position.y -= 200
	global_position.x += 20 * sign(witch().graphics.scale.x)
