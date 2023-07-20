extends Panel

func _get_drag_data(_position: Vector2):
	AppNodeConstants.get_root().set_currently_dragged_item(self.owner)
	print("get_drag_data has started")
	%Container.items_visible(false)
	set_drag_preview(_get_preview_control())
	self.owner.modulate.a = 0

	return self.owner




func _get_preview_control() -> Control:
	var dup = self.owner.duplicate(0)
	dup.size = size
	
	return dup


func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
