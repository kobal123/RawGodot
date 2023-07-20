extends HSlider

signal value_changed_with_group(_value,_group)

signal change_buffer(ID: int, buf_data: PackedByteArray, at_position:int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func set_value_changed_calls():
	pass

func _on_spin_box_value_changed(_value):
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

#func update_mask_buffer(_name: String, buf_index: int, buf_data: PackedByteArray, at_position:int = 0):
