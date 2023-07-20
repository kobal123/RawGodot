extends GridContainer

var scene_res: PackedScene = preload("res://image_thumbnail.tscn")
var libraw = RawThumbnailLoader.new()
var libraw2 = RawThumbnailLoader.new()
var libraw3 = RawThumbnailLoader.new()
var libraw4 = RawThumbnailLoader.new()

var thumbnail_loaders = []
var used_loaders = []
var current_dir;

var threads: Array[Thread] = []


# Called when the node enters the scene tree for the first time.

func _ready():
	for i in 4:
		thumbnail_loaders.push_back(RawThumbnailLoader.new())
	
	
	
var load_thumbnail_callable: Callable = func(_position) -> void:

	var tree = %FileSystemTree
#	var img = get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/Control2/myImageNode")
	var img = AppNodeConstants.get_image_node()
	var item: TreeItem = tree.get_item_at_position(_position)	
	var split_str:PackedStringArray = item.get_text(0).split(".")
	if(split_str.size()==1):
		
		for c in self.get_children():
			remove_child(c)
			c.queue_free()
		var item_children = item.get_children()
		for _child in item_children:
			var child_text_split = _child.get_text(0).split(".")
			if child_text_split.size() == 2 and child_text_split[1] in tree.get_image_extensions():
#				print(_child.get_text(0))

			
				var full_img_path:String = tree.get_full_path(_child)
				#full_img_path = full_img_path.replace("/","\\\\")
#				print("full img path: ",full_img_path)
				#return
				var scene = scene_res.instantiate()
				scene.path_ = full_img_path
				var s = Time.get_ticks_msec()
				var i:Image = libraw.load_thumbnail(full_img_path)
				scene.setup_(ImageTexture.create_from_image(i),_child.get_text(0), _child)
				var e = Time.get_ticks_msec()
				print("LOADING THUMBNAILS TOOK: ",e-s)
				add_child(scene)
	else:
		img._on_file_dialog_file_selected(tree.get_full_path(item))
		AppNodeConstants.get_file_system_node().set_current_image_tree_item(item)

func _on_tree_item_mouse_selected(_position, _mouse_button_index):
	print("item clicked at position: ", _position)

	var tree = %FileSystemTree
#	var img = get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/Control2/myImageNode")
	var img = AppNodeConstants.get_image_node()
	var item: TreeItem = tree.get_item_at_position(_position)	
	var split_str:PackedStringArray = item.get_text(0).split(".")
	if(split_str.size()==1):
		
		for c in self.get_children():
			remove_child(c)
			c.queue_free()
		var item_children = item.get_children()
		for _child in item_children:
			var child_text_split = _child.get_text(0).split(".")
			if child_text_split.size() == 2 and child_text_split[1] in tree.get_image_extensions():
#				print(_child.get_text(0))

			
				var full_img_path:String = tree.get_full_path(_child)
				#full_img_path = full_img_path.replace("/","\\\\")
#				print("full img path: ",full_img_path)
				#return
				var scene = scene_res.instantiate()
				scene.path_ = full_img_path
				var s = Time.get_ticks_msec()
				var i:Image
				if child_text_split[1].to_lower() not in ["jpeg", "jpg", "png"]:
					var image_and_original_size = libraw.load_thumbnail_with_original_size(full_img_path)
	#				var i:Image = libraw.load_thumbnail(full_img_path)
					i = image_and_original_size[0]
					var sizes: Vector2 = image_and_original_size[1]
					scene.setup_(ImageTexture.create_from_image(i),_child.get_text(0), _child)
					scene.set_size_label(str(sizes.x) +"x"+str(sizes.y))
					var e = Time.get_ticks_msec()
					print("LOADING THUMBNAILS TOOK: ",e-s)
					add_child(scene)
				else:
					i = Image.load_from_file(full_img_path)
					scene.setup_(ImageTexture.create_from_image(i), _child.get_text(0), _child)
					scene.set_size_label(str(i.get_size().x) +"x"+str(i.get_size().y))
					var e = Time.get_ticks_msec()
					print("LOADING THUMBNAILS TOOK: ",e-s)
					add_child(scene)
				
		columns = item_children.size()

	else:
		img._on_file_dialog_file_selected(tree.get_full_path(item))
		AppNodeConstants.get_file_system_node().set_current_image_tree_item(item)

#	print("item text is ", item.get_text(0))
#	var item_text = item.get_text(0)
#	var split_str:PackedStringArray = item_text.split(".")
#	if(split_str.size()==2):
#
#		var libraw = LibRawRef.new()
#		var full_img_path:String = tree.get_full_path(item)
#		#full_img_path = full_img_path.replace("/","\\\\")
#		print("full img path: ",full_img_path)
#		#return
#		var scene = scene_res.instantiate()
#
#		var i:Image = libraw.load_thumbnail(full_img_path)
#		scene.setup_(ImageTexture.create_from_image(i),item_text)
#		add_child(scene)



#func _on_resized():
#	return
#	print("SETTING SIZE OF CHILDREN")
#	for c in get_children():
#		c.set_size(Vector2(c.size.x, self.size.y))
#		print("SETTING SIZE OF CHILDREN")


func _on_scroll_container_resized():
	var new_height = max(get_parent().size.y, 200)
	for c in get_children():

		c.custom_minimum_size = (Vector2(new_height * 1.4, new_height))
#		print("SETTING SIZE OF CHILDREN")
