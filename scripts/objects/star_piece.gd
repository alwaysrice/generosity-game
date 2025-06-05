class_name StarPiece extends Node2D

@export var texture: Texture2D

func _ready() -> void:
	$Sprite2D.texture = texture
