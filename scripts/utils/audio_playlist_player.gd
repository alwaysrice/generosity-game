class_name AudioPlaylistPlayer extends AudioStreamPlayer


@export var end = 2.0
@export var fade = 0.5
@export var is_looping = true
@export var playlist: Array[AudioStream] = []
var current = 0
var end_timer: Timer
var fade_tween: Tween
signal finished_all


func add_music(music: AudioStream):
	playlist.append(music)
	
func clear_playlist():
	stream = null
	stop()
	current = 0
	playlist.clear()
	end_timer.stop()


func play_next():
	assert(playlist.size() > 0)
	stream = playlist[current]
	end_timer.wait_time = min(end - fade, stream.get_length())
	end_timer.start()
	end_timer.timeout.connect(_fade_play, CONNECT_ONE_SHOT)
	play()
	
	
func _ready() -> void:
	end_timer = Timer.new()	
	end_timer.one_shot = true
	add_child(end_timer)


func _fade_play():
	var last_volume = volume_db
	fade_tween = create_tween()
	fade_tween.tween_property(self, "volume_db", 0, fade)
	fade_tween.tween_callback(func():
		stop()
		volume_db = last_volume
		current += 1
		if current >= playlist.size():
			current = 0
			if not is_looping:
				finished_all.emit()
			else:
				play_next()
		else:
			play_next()
		)		
