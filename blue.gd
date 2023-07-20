extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var dragging: bool = false
var drag_start_pos

func _gui_input(event):
	if event is InputEventMouseMotion:
		if dragging:
			if event.position.x < drag_start_pos.x:

				print("DRAGGING RIGHT")
				if value == max_value:
#					set_size(Vector2(size.x + event.position.x - drag_start_pos.x, size.y))
#					drag_start_pos = event.position
					var delta = event.position.x - drag_start_pos.x
#					set_size(Vector2(size.x + delta, size.y))
#					print("SETTING SIZE: ", %green.size.x - delta)
#					%red.set_size(Vector2(%red.size.x - delta,%red.size.y ))
#					drag_start_pos = event.position
			elif event.position.x > drag_start_pos.x:
				print("DRAGGING LEFT")
				if value == max_value:
					var delta = event.position.x - drag_start_pos.x
					set_size(Vector2(size.x + delta, size.y))
#					print("SETTING SIZE: ", %green.size.x - delta)
					%red.set_size(Vector2(%red.size.x - delta,%red.size.y ))
#					drag_start_pos = event.position
#					%red.max_value -= 1
#					%red.value -= 1
#					max_value += 1
					
			else:
				print("BUG")
		drag_start_pos = event.position
	print("RED: ", value, ", BLUE: ", %blue.value, ", GREEN: ", abs(100 - value - %blue.value))

func _value_changed(new_value):
	print("val changed: ", new_value)
#	pass

func _on_drag_started():
	print("DRAG HAS STARTED")
	dragging = true
	drag_start_pos = get_local_mouse_position()
	get_parent().move_child(self, 1)
	
func _on_drag_ended(value_changed):
	dragging = false
	drag_start_pos = null
