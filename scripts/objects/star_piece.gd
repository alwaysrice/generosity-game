class_name StarPiece extends Node2D

var collected = false
func collect(callback: Callable = func():pass):
	if collected:
		return
	collected = true
	print("Collecting start")
	$AnimationPlayer.play(&"collect")
	$AnimationPlayer.animation_finished.connect(func(anim):
		if callback:
			callback.call()
		, CONNECT_ONE_SHOT)
