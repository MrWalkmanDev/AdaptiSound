extends Node

#class_name Tools

const EXTENSION_ANDROID = "import"

### FILE SYSTEM ###

func files_load(path, extension):
	if path == null:
		return {}
		
	var sounds = {}
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			
			if extension.has(file_name.get_extension()):
				
				var file_name_to_load : String
				var file_name_key : String
				
				"""if OS.get_name() == "Android":
					print("Android")
					file_name_to_load = (dir.get_current_dir() + "/" + file_name).replace("." + EXTENSION_ANDROID, "")
					file_name_key = file_name.replace("." + file_name.get_extension() + "." + EXTENSION_ANDROID, "")
					sounds[file_name_key] = load(file_name_to_load)
				if OS.get_name() == "Web":
					print("Web")
					file_name_to_load = (dir.get_current_dir() + "/" + file_name).replace("." + EXTENSION_ANDROID, "")
					file_name_key = file_name.replace("." + file_name.get_extension() + "." + EXTENSION_ANDROID, "")
					sounds[file_name_key] = load(file_name_to_load)
				if OS.get_name() == "X11":
					print("X11")
					file_name_to_load = (dir.get_current_dir() + "/" + file_name).replace("." + EXTENSION_ANDROID, "")
					file_name_key = file_name.replace("." + file_name.get_extension() + "." + EXTENSION_ANDROID, "")
					sounds[file_name_key] = load(file_name_to_load)
				if OS.get_name() == "Windows":
					print("Windows")
					file_name_to_load = (dir.get_current_dir() + "/" + file_name).replace("." + EXTENSION_ANDROID, "")
					file_name_key = file_name.replace("." + "ogg" + "." + EXTENSION_ANDROID, "")
					sounds[file_name_key] = load(file_name_to_load)"""
				if extension.has(file_name.get_extension()):
					file_name_to_load = (dir.get_current_dir() + "/" + file_name)
					file_name_key = file_name.replace("." + file_name.get_extension(), "")
					sounds[file_name_key] = load(file_name_to_load)
			
			if dir.current_is_dir():
				var subfolder = path + "/" + file_name
				var sub_sounds = files_load(subfolder, extension)
				sounds.merge(sub_sounds)
			
			file_name = dir.get_next()
		
		return sounds
		
	else:
		if !Engine.is_editor_hint():
			AudioManager.debug._print("DEBUG: Directory not found in path " + str(path))
			return {}
	
func preload_adaptive_tracks(path):
	if path == null:
		return {}
		
	var tracks = {}
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.get_extension() == "tscn":
				var file_name_to_load : String
				var file_name_key : String
				
				file_name_to_load = (dir.get_current_dir() + "/" + file_name)
				file_name_key = file_name.replace("." + file_name.get_extension(), "")
				tracks[file_name_key] = load(file_name_to_load)
			
			if dir.current_is_dir():
				var subfolder = path + "/" + file_name
				var sub_sounds = preload_adaptive_tracks(subfolder)
				tracks.merge(sub_sounds)
			
			file_name = dir.get_next()
		
		return tracks
		
	else:
		if !Engine.is_editor_hint():
			AudioManager.debug._print("DEBUG: Directory not found in path " + str(path))
			return {}
