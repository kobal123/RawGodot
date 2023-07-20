extends ImageTextEdit

var img = Image.load_from_file("res://square.png")
var img2 = Image.load_from_file("res://ttttt.png")

@export var img_positions: PackedVector2Array = []
@export var images: Array[Image] = []

var has_text_changed: bool = false
var has_line_edit_changed: bool = false

@export var _name: String = ""

var file_name_prefix: String = "node__"


var line_edit

# Called when the node enters the scene tree for the first time.
func _ready():
	
	line_edit = get_parent().get_line_edit()
	img.resize(64,64,Image.INTERPOLATE_LANCZOS)
	TextImageTexture.create_from_image__(img)
	for c in get_children():
		c.owner = self
	# if images not empty insert every image
	_insert_images()

func _insert_images():
	var image_index = 0;
	for image_pos in img_positions:
		set_caret_line(image_pos.x)
		set_caret_column(image_pos.y)
		insert_image_at_caret(TextImageTexture.create_from_image__(images[image_index]), 0, true)
		image_index += 1


func _on_button_pressed():
	var i = TextImageTexture.create_from_image__(img)
	insert_image_at_caret(i, 0, true)
	


func _on_button_2_pressed():
	insert_image_at_caret(TextImageTexture.create_from_image__(img2),0, true)
	

#func _notification(what):
#	if what == NOTIFICATION_WM_CLOSE_REQUEST:
#		# only clear items if text changed
#		if has_text_changed:
#			images.clear()
#			img_positions.clear()
#			for line_ in get_line_count():
#				var line_images = get_images(line_);
#				for image in line_images:
#					var texture_: TextImageTexture = image as TextImageTexture
#					images.append(texture_.get_image())
#					img_positions.append(Vector2(texture_.get_line_col()))
#
#		var packed = PackedScene.new()
#		self.owner = get_parent()
#		var pack_error = packed.pack(self)
#		if pack_error != OK:
#			print("THERE WAS AN ERROR PACKING THE SCENE")
#			return
#
#		var file_name = get_node_file_name()
#		if file_name == "":
#			print("GIVE A NAME TO THE NODE")
#			return
#		var save_error = ResourceSaver.save(packed,"res://" + file_name)
#
#		if save_error != OK:
#			print("THERE WAS AN ERROR SAVING THE SCENE")
#		print("EXITING")
#		get_tree().quit() # default behavior
#
#func get_node_file_name():
#	DirAccess.dir_exists_absolute()
#	if line_edit == null:
#		return
#	var file_name: String = file_name_prefix + line_edit.text
#	file_name = file_name.lstrip(" ").rstrip(".").replace(" ", ".")
#	var i = 0;
#
#	while true:
#		if ResourceLoader.exists(file_name + ".tscn"):
#			file_name += str(i)
#			continue
#		break
#	file_name += ".tscn"
#
#	return file_name

func _on_text_changed():
	has_text_changed = true


func _on_line_edit_text_changed(new_text):
	has_line_edit_changed = true
