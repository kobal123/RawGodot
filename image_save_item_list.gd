extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	select(0) # select JPG as default image format
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_selected(index: int):
	var saveButton: IMG_SAVE_BUTTON = %SaveButton
	if get_item_text(index) == "JPG":
		saveButton.set_img_type(IMG_SAVE_BUTTON.IMG_TYPE.JPG)
		%JpegQuality.visible = true
	elif get_item_text(index) == "PNG":
		%JpegQuality.visible = false
		saveButton.set_img_type(IMG_SAVE_BUTTON.IMG_TYPE.PNG)
