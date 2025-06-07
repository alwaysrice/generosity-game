class_name AudioPlayer extends AudioStreamPlayer


@export var normal_volume: float
	

func fade_to_stop(time=1.0, callback=func():pass, from=0.0):
	var music_tween = create_tween()
	music_tween.tween_property(self, "volume_db", -60, time)
	music_tween.tween_callback(func():
		stop()
		volume_db = normal_volume
	)
	if callback:
		music_tween.tween_callback(callback)

func fade_to_play(time=1.0, callback=func():pass, from=0.0):
	var music_tween = create_tween()
	volume_db = 0
	music_tween.tween_property(self, "volume_db", normal_volume, time)
	if callback:
		music_tween.tween_callback(callback)
	play(from)
	
func fade_to_normal(time=1.0, callback=func():pass, from=0.0):
	var music_tween = create_tween()
	volume_db = 0
	music_tween.tween_property(self, "volume_db", normal_volume, time)
	if callback:
		music_tween.tween_callback(callback)
	
