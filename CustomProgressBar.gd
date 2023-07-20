extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw():
	draw_rect(Rect2(0,0,%TextureRect.position.x,8), Color.RED)
	draw_rect(Rect2(%TextureRect.position.x, 0,%TextureRect2.position.x - %TextureRect.position.x, 8), Color.GREEN)
	draw_rect(Rect2(%TextureRect2.position.x, 0, size.x - %TextureRect2.position.x, 8), Color.BLUE)



var pressed: bool = false
var drag_pos_start

var dragging_left: bool = false
var dragging_right: bool = false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if abs(event.position.x - %TextureRect.position.x) < 15:
				pressed = true
#				print("DRAG STARTED")
				drag_pos_start = event.position
				dragging_left = true
			elif abs(event.position.x - %TextureRect2.position.x) < 15:
				pressed = true
#				print("DRAG STARTED")
				drag_pos_start = event.position
				dragging_right = true
		else:
#			print(abs(event.position.x- position.x))
			pressed = false
			dragging_left = false
			dragging_right = false
#			print("DRAG ENDED")
	if event is InputEventMouseMotion and pressed:
		if dragging_left:
			var delta = drag_pos_start.x - %TextureRect.position.x
			if event.position.x > drag_pos_start.x and abs(%TextureRect.position.x - %TextureRect2.position.x)<10:
				%TextureRect.position.x += delta
				%TextureRect2.position.x += delta
			else:
				%TextureRect.position.x += delta
#			print("DELTA: ", delta)
#			print(%TextureRect.position.x)
	#		value = %TextureRect.position.x
			
			drag_pos_start = event.position
		if dragging_right:
			var delta = drag_pos_start.x - %TextureRect2.position.x
			if event.position.x < drag_pos_start.x and abs(%TextureRect.position.x - %TextureRect2.position.x)<10:
				%TextureRect2.position.x += delta
				%TextureRect.position.x += delta
			else:
				%TextureRect2.position.x += delta
			
#			%TextureRect2.position.x += delta
#			print("DELTA: ", delta)
#			print(%TextureRect2.position.x)
	#		value = %TextureRect.position.x
			
			drag_pos_start = event.position
			
			
	if %TextureRect.position.x < 0:
		%TextureRect.position.x = 0
	if %TextureRect.position.x > size.x - 11:
		%TextureRect.position.x = size.x - 11

	if %TextureRect2.position.x < 11:
		%TextureRect2.position.x = 11
	if %TextureRect2.position.x > size.x:
		%TextureRect2.position.x = size.x
	print("RED: ", (%TextureRect.position.x + 5.0) / size.x, ", BLUE: ",( size.x - %TextureRect2.position.x + 5.0) / size.x, ", GREEN: ", (%TextureRect2.position.x - %TextureRect.position.x - 10)/size.x)
	%red.set_block_signals(true)
	%red.value = (%TextureRect.position.x + 5.0) / size.x
	%red.set_block_signals(false)
	%blue.value = ( size.x - %TextureRect2.position.x + 5.0) / size.x
	%green.value = (%TextureRect2.position.x - %TextureRect.position.x - 10)/size.x
	queue_redraw()
	update_buffer()



func update_buffer():
#	if self.owner.transform_function:
#		var d:PackedFloat32Array = self.owner.transform_function.call(_value) 
#
##		emit_signal("change_buffer",self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position)
#		ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position])
#
#
##	emit_signal("value_changed_with_group",_value,self.owner.ID)
#
#	else:
	var d:PackedFloat32Array = [%red.value, %green.value, %blue.value]
	
#		emit_signal("change_buffer",self.owner.BUFFER_OWNER_ID,d.to_byte_array(), self.owner.updates_at_position)
	ComputePipeLineManager.callv("_update_buffer",[self.owner.BUFFER_OWNER_ID, d.to_byte_array(), self.owner.updates_at_position])
#	print("UPDATED BUFFER WITH VALUES: ", d)
	ComputePipeLineManager.apply_effects(self.owner.BUFFER_OWNER_ID)



func _on_red_value_changed(value):
	%TextureRect.position.x = (value) * size.x
