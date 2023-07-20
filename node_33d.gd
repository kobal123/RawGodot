extends Sprite3D

var s = preload("res://NEXT_PASS.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("VIEWPORT ID", get_viewport().get_viewport_rid())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
