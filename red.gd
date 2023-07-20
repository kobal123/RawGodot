extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var dragging: bool = false
var drag_start_pos

var blue_val_added = 0

var value_overflow = 0


func _gui_input(event):
	if event is InputEventMouseMotion:
		if dragging:
			if event.position.x < drag_start_pos.x:
#				print("DRAGGING LEFT")
				if value == max_value:
#					set_size(Vector2(size.x + event.position.x - drag_start_pos.x, size.y))
#					drag_start_pos = event.position
					var delta = event.position.x - drag_start_pos.x
#					set_size(Vector2(size.x + delta, size.y))
#					print("SETTING SIZE: ", %green.size.x - delta)
#					%green.set_size(Vector2(%green.size.x - delta,%green.size.y ))
#					drag_start_pos = event.position
			elif event.position.x > drag_start_pos.x:
#				print("DRAGGING RIGHT")
				if value == max_value:
					var delta = event.position.x - drag_start_pos.x
					set_size(Vector2(size.x + delta, size.y))
					value_overflow += delta/2
					max_value += delta/2
					value += delta/2
#					print("SETTING SIZE: ", %blue.size.x - delta)
#					%blue.set_size(Vector2(%blue.size.x - delta,%blue.size.y ))
#					%green.max_value -= 1
#					%blue.value += 1
#					max_value += 1
#					if %green.size.x / delta >500: 
#						%green.value = %green.value + 1
#						blue_val_added += 1
#					drag_start_pos = event.position
			else:
				print("BUG")
		drag_start_pos = event.position
	print("RED: ", value, ", BLUE: ", %blue.value, ", GREEN: ", abs(100 - value - %blue.value))

func _value_changed(new_value):
	pass
#	print("val changed")

func _on_drag_started():
#	print("DRAG HAS STARTED")
	dragging = true
	drag_start_pos = get_local_mouse_position()
	get_parent().move_child(self, 1)
func _on_drag_ended(value_changed):
	dragging = false
	drag_start_pos = null
