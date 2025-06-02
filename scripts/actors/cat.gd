class_name Cat extends Actor


func witch():
	return following as Witch

func _ready() -> void:
	pass


func join_fly():
	is_joining = true
	velocity = Vector2.ZERO
	graphics.scale.x = witch().graphics.scale.x
	global_position = witch().global_position 
	global_position.y -= 200
	global_position.x = witch().graphics.get_node("Broom/Dest").global_position.x
	
	var witch = following as Witch
	witch.done_flying.connect(func():
		has_joined_other = false
		, CONNECT_ONE_SHOT)
	witch.broom.body_entered.connect(func(body: Node2D):
		var sprite = $Graphics.get_child(0)
		if sprite is AnimatedSprite2D and sprite.animation == "fall":
			is_joining = false
			has_joined_other = true
			global_position = witch().graphics.get_node("Broom/Dest").global_position
			global_position -= %Offset.position
			stop()
			sprite.play("flight")
		, CONNECT_ONE_SHOT)
