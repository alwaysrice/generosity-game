extends Node2D

func list_files_in_folder(folder_path: String) -> Array[String]:
	var dir := DirAccess.open(folder_path)
	var array = []
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".mp3"):
			array.append(file_name)
	dir.list_dir_end()
	return array
	
func _ready() -> void:
	list_files_in_folder("res://audio/dialogue set 1")
