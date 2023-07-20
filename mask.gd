extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_overlay_check_box_toggled(button_pressed):
	if button_pressed:
		AppNodeConstants.get_mask_overlay().material.set_shader_parameter("killswitch", 1.0)
		
		MaskDrawingMaster.editing = button_pressed
	else:
		MaskDrawingMaster.editing = button_pressed
		AppNodeConstants.get_mask_overlay().material.set_shader_parameter("killswitch", 0.0)
		MaskDrawingMaster.update_mask()


func _on_color_picker_button_color_changed(color):
	AppNodeConstants.get_mask().material.set_shader_parameter("color", color)
	AppNodeConstants.get_mask_overlay().set_color(color)
	AppNodeConstants.get_clip_drawing_overlay().set_color(color)

func _on_mouse_entered():
	pass
#	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)

func disable_overlay():
	%OverlayCheckBox.set_pressed(false)

func _on_check_button_toggled(button_pressed):
	MaskDrawingMaster.toggle_erasing()
	MaskDrawingMaster.update_mask()


func _on_brush_slider_value_changed(value):
	MaskDrawingMaster.set_brush_size(value)
