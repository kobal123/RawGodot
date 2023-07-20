class_name IMG_SAVE_BUTTON
extends Button

var jpeg_quality:float = 0.75

enum IMG_TYPE{
	JPG,
	PNG
}

var img_type: IMG_TYPE = IMG_TYPE.JPG

func set_img_type(type_: IMG_TYPE):
	img_type = type_

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	var tex = ComputePipeLineManager.get_current_texture()
	var img = tex.get_image()
	var img_path := remove_image_path_extension(%LineEdit.text)
	if img_type == IMG_TYPE.JPG:
		img_path += ".jpg"
		img.save_jpg(img_path, jpeg_quality)
		print("SAVED IMAGE TO: ", %LineEdit.text)
	elif img_type == IMG_TYPE.PNG:
		img_path += ".png"
		img.save_png(img_path)
	self.owner.hide()

func remove_image_path_extension(path_: String) -> String:
	var split_str:= path_.split(".")
	split_str.remove_at(split_str.size() - 1)
	return ".".join(split_str)

func _on_h_slider_value_changed(value):
	jpeg_quality = value
