extends SpinBox
signal value_changed_with_group(_value,_group)


signal change_buffer(ID: int, buf_data: PackedByteArray, at_position:int)


func _on_h_slider_value_changed(_value):
	set_block_signals(true)
	value = float(_value)
	set_block_signals(false)

func _on_value_changed(_value):
	if self.owner.mask_name == "":
		return
	AppNodeConstants.get_mask_manager().disable_overlay()
	if self.owner.transform_function:
		var d:PackedFloat32Array = self.owner.transform_function.call(_value) 
		
#		emit_signal("change_buffer",self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position)
#		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
		ComputePipeLineManager.callv("update_mask_buffer",[self.owner.mask_name, self.owner.BUFFER_OWNER_ID, d.to_byte_array(), self.owner.updates_at_position])

#	emit_signal("value_changed_with_group",_value,self.owner.ID)
	elif self.owner.IS_DATA_INT:
		var d:PackedInt32Array = [_value]
		
#		emit_signal("change_buffer",self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position)
#		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
		ComputePipeLineManager.callv("update_mask_buffer",[self.owner.mask_name, self.owner.BUFFER_OWNER_ID, d.to_byte_array(), self.owner.updates_at_position])
	else:
		var d:PackedFloat32Array = [_value]
		
#		emit_signal("change_buffer",self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position)
#		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
		ComputePipeLineManager.callv("update_mask_buffer",[self.owner.mask_name, self.owner.BUFFER_OWNER_ID, d.to_byte_array(), self.owner.updates_at_position])
	ComputePipeLineManager.apply_effects(self.owner.BUFFER_OWNER_ID)
