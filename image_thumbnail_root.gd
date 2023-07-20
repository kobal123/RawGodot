extends ColorRect



var dark = Color(45.0/255.0,45.0/255.0,45.0/255.0,1.0)
var light_ = Color(60.0/255.0,60.0/255.0,60.0/255.0,1.0)

var path_:String

var path_tree_item: TreeItem

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	color = dark

func setup_(_texture, imgName:String, item: TreeItem):
	var imgTextureRect = %imgTextureRect
	var imgNameLabel = %ImageNameLabel
	imgNameLabel.text = imgName
	imgTextureRect.texture = _texture
	path_tree_item = item
	
#	imgNameLabel.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER) 

func set_size_label(label_text):
	%sizeLabel.text = label_text

func _on_mouse_entered():
	return
	self.color= light_
	set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	
func _on_mouse_exited():
	return
	self.color= dark
	set_default_cursor_shape(Control.CURSOR_ARROW)


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var img = AppNodeConstants.get_image_node()
			img.load_image(AppNodeConstants.get_file_system_node().get_full_path(path_tree_item))
