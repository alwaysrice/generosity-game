class_name StarPiece extends Node2D

var collected = false
func collect(callback: Callable):
	if collected:
		return
	collected = true
	$AnimationPlayer.play(&"collect")
	$AnimationPlayer.animation_finished.connect(func(anim):
		callback.call()
		, CONNECT_ONE_SHOT)
