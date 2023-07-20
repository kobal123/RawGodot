extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _pressed():
	AppNodeConstants.get_clip_drawing_overlay().visible = !AppNodeConstants.get_clip_drawing_overlay().visible
	if ComputePipeLineManager.is_clipping:
		ComputePipeLineManager.clipping_finished()
	else:
		ComputePipeLineManager.clipping_started()
		%ApplyCrop.show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_apply_crop_pressed():
	var crop_rect = AppNodeConstants.get_clip_drawing_overlay().get_crop_rect()
	AppNodeConstants.get_clip_drawing_overlay().visible = false
	ComputePipeLineManager.clipping_finished()
	ComputePipeLineManager.set_clip_buffer(crop_rect)
	print("CROP RECT: ", crop_rect)
	%ApplyCrop.hide()
