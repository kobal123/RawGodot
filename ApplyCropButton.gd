extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _pressed():
	var crop_rect = AppNodeConstants.get_clip_drawing_overlay().get_crop_rect()
	AppNodeConstants.get_clip_drawing_overlay().visible = false
	ComputePipeLineManager.clipping_finished()
	ComputePipeLineManager.set_clip_buffer(crop_rect)
	print("CROP RECT: ", crop_rect)
#	%ApplyCrop.hide()
