extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	pass



func _on_toggled(button_pressed):
	print("BUTTON PRESSED!!!")
	print("CALLING FUCNTION ", self.owner.value_changed_callback)
	self.owner.value_changed_callback.callv([button_pressed, self.owner.IS_DATA_INT, self.owner.IS_DATA_BOOL, self.owner.BUFFER_OWNER_ID,  self.owner.updates_at_position])
	ComputePipeLineManager.apply_effects(self.owner.BUFFER_OWNER_ID)
	ComputePipeLineManager.apply_histo()
