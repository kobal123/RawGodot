extends Tree

var loaded_directories = []
var main_root;
var root;
var root_directory;

var current_highlighted_item:TreeItem;

var last_item_folded;


var current_image_tree_item: TreeItem
var path_to_current_image: String

# Create new ConfigFile object.
var config = ConfigFile.new()

signal path_changed(path: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load data from a file.
	
	var err = config.load("user://last_image.cfg")
	

# If the file didn't load, ignore it.
	if err != OK:
		print("ERROR LOADING CONFIG")
		return


# Iterate over all sections.
	print(config.get_value("IMAGE","IMAGE_PATH","DEFAULT_VALUE"))
	var path_to_image = config.get_value("IMAGE","IMAGE_PATH","DEFAULT_VALUE")
	var path_full:PackedStringArray = path_to_image.split("/")
	var path_ = path_full.slice(0,-1)
	path_to_current_image = "/".join(path_)
	emit_signal("path_changed", path_to_current_image)
	_on_file_dialog_dir_selected(path_to_current_image)
	print("PATH FULL: ", "".join(path_full))
	AppNodeConstants.get_image_node().set_preload_image_path(path_to_image)
	return





func _gui_input(event):
	
	if event is InputEventMouseMotion:
		if event.button_mask != MOUSE_BUTTON_MASK_MIDDLE:
			
			var item = get_item_at_position(event.position)

			if item == null:
				mouse_default_cursor_shape = Control.CURSOR_ARROW
				if current_highlighted_item != null:
					current_highlighted_item.clear_custom_bg_color(0)
					current_highlighted_item = null
					
					#current_highlighted_item.set_custom_bg_color(0,Color(70.0/255.0,70.0/255.0,70.0/255.0,1.0))
			else:
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				if current_highlighted_item != null:
					current_highlighted_item.clear_custom_bg_color(0)
					current_highlighted_item = item
				
					current_highlighted_item.set_custom_bg_color(0,Color(70.0/255.0,70.0/255.0,70.0/255.0,1.0))
				else:
					current_highlighted_item = item
					current_highlighted_item.set_custom_bg_color(0,Color(70.0/255.0,70.0/255.0,70.0/255.0,1.0))

func get_dir_contents(rootPath: String) -> Array:
	#print("getting contents for directory: " + rootPath)
	var files = []
	var directories = []
	var dir = DirAccess.open(rootPath)
	dir.list_dir_begin()
	

	_add_dir_contents(dir, files, directories)

	return [files, directories]

var image_extensions = ["ARW","arw","NEF","nef", "JPEG", "jpeg", "JPG", "jpg", "PNG", "png"]

func get_image_extensions():
	return image_extensions

func _add_dir_contents(dir: DirAccess, files: Array, directories: Array):
	var file_name: String = dir.get_next()

	while (file_name != ""):
		#print(file_name)
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			print("APPENDING DIRECTORY", path)
			directories.append(path)
		else:
			var split_str:PackedStringArray = file_name.split(".")
			if(split_str.size() == 2 and split_str[1] in image_extensions):
				print("APPENDING FILE ", path)
				files.append(path)
			
		file_name = dir.get_next()
	
	dir.list_dir_end()


func _on_file_dialog_dir_selected(dir):
	#get_dir_contents(dir)
	for c in get_children():
		remove_child(c)
		c.free()
	clear()
	loaded_directories.resize(0)
	root = create_item(main_root)
	
	root.set_text(0,dir)
	root_directory = dir
	create_item(root)
	_on_item_collapsed(root)


func _on_item_collapsed(item: TreeItem, _boolean=true):

	var t_f_path = get_full_path(item)
	if loaded_directories.has(t_f_path):
		return
	else:
		loaded_directories.append(t_f_path)
		var path_to_item = []
		var parent_item = item
		path_to_item.append(item.get_text(0))
		while true:
			parent_item = parent_item.get_parent()
			if parent_item == null or parent_item == root:
				path_to_item.append(root.get_text(0))
				break
			else:
				path_to_item.append(parent_item.get_text(0))
		
		path_to_item.reverse()
		var joined_string = PackedStringArray(path_to_item)
		var files_dirs;
		if root_directory != item.get_text(0):
			files_dirs = get_dir_contents("/".join(joined_string))
		else:
			files_dirs = get_dir_contents(root_directory)
		
		for file in files_dirs[0]:
			#print("item is ",item)
			#print("item text is ",item.get_text(0))
		
			var child = item.create_child()
			var split_str = file.split("/")
			child.set_text(0,split_str[split_str.size()-1])

		for directory in files_dirs[1]:
			#print("item is ",item)
			#print("item text is ",item.get_text(0))
#			print("CREATING NEW CHILD DIRECTORY")
			#.set_text("test child")
			
			var child: TreeItem = item.create_child()
			
			var split_str = directory.split("/")
			child.set_text(0,split_str[split_str.size()-1])
			#child.disable_folding = false
			#child.disable_folding = true
			#child.disable_folding = false
			var sub_child = child.create_child()
			#sub_child.visible = false
			set_block_signals(true)
			child.collapsed = true
			set_block_signals(false)
			


func _on_item_double_clicked():
	print("item double click")


func _on_cell_selected():
	print("cell selected")
	pass # Replace with function body.


func _on_item_selected():
	print("item selected")
	pass # Replace with function body.



func get_full_path(item: TreeItem)->String:
	var path_to_item = []
	var parent_item = item
	path_to_item.append(item.get_text(0))
	while true:
		parent_item = parent_item.get_parent()
		if parent_item == null or parent_item == root:
			path_to_item.append(root.get_text(0))
			break
		else:
			path_to_item.append(parent_item.get_text(0))
	path_to_item.reverse()
	#var temp = PackedStringArray(path_to_item)
	return "/".join(PackedStringArray(path_to_item))


func _on_mouse_exited():
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	if current_highlighted_item:
		current_highlighted_item.clear_custom_bg_color(0)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if current_image_tree_item != null:
			print("QUITTING APPLICATION")
			print("CURRENT ITEM IMAGE PATH: ", get_full_path(current_image_tree_item))
			config.set_value("IMAGE","IMAGE_PATH",get_full_path(current_image_tree_item))
			config.save("user://last_image.cfg")
			
		get_tree().quit() # default behavior


func set_current_image_tree_item(item_: TreeItem):
	current_image_tree_item = item_
	path_to_current_image = get_full_path(current_image_tree_item)
	emit_signal("path_changed", path_to_current_image)
