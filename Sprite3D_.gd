extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var image:Image = Image.load_from_file("res://sony.ARW")
	var textu = ImageTexture.create_from_image(image)
	self.texture = textu
	

	print(texture.get_height())
	print(texture.get_width())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
