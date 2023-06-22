@tool
extends Control

var audio_pool = {}

func _ready():
	pass
	
func file_names_updated(files):
	while $ItemList.get_child_count() > 0:
		var child_node = $ItemList.get_child(0)
		$ItemList.remove_child(child_node)
		child_node.queue_free()
	
	for i in range(0, files.size()):
		var file_line : Label = Label.new()
		file_line.set_name("File_" + str(i))
		file_line.set_text(files[i].get_file())
		
		# Add the nodes into the dock scene
		$ItemList.add_child(file_line)
		#$ItemList.add_item(files[i].get_file())
		#file_list.add_child(file_name_container)
