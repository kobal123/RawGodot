extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = AppNodeConstants.get_file_system_node().path_to_current_image
	AppNodeConstants.get_file_system_node().connect("path_changed", Callable(self,"set_text"))

#func set_text(text_: String):
#	text = text_

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
