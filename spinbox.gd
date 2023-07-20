extends SpinBox
signal value_changed_with_group(_value,_group)


signal change_buffer(ID: int, buf_data: PackedByteArray, at_position:int)


func _on_h_slider_value_changed(_value):
	set_block_signals(true)
	value = float(_value)
	set_block_signals(false)

func _on_value_changed(_value):
	if self.owner.value_changed_callback != null:
		print("calling custom callable")
		self.owner.value_changed_callback.callv([_value, self.owner.IS_DATA_INT, self.owner.IS_DATA_BOOL, self.owner.BUFFER_OWNER_ID,  self.owner.updates_at_position])

	
	elif self.owner.transform_function:
		var d:PackedFloat32Array = self.owner.transform_function.call(_value) 
		
		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
		

	elif self.owner.IS_DATA_INT:
		var d:PackedInt32Array = [_value]
		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
		
	else:
		var d:PackedFloat32Array = [_value]		
		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])

	ComputePipeLineManager.apply_effects(self.owner.BUFFER_OWNER_ID)
	ComputePipeLineManager.apply_histo()
