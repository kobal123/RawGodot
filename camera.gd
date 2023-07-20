extends Camera2D


var target_zoom: float = 1.0
const MIN_ZOOM: float = 1.0
const MAX_ZOOM: float = 2.0
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 8.0


func _physics_process(delta):
	zoom = lerp(zoom, target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, target_zoom))

func zoom_in():
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_out():
	target_zoom = max(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)



func _unhandled_input(event):
	return
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("up")
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("down")
				zoom_out()
				

func _input(event):
	return
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			position -= event.relative * (Vector2.ONE/zoom)	



func _on_image_container_item_rect_changed():
	pass # Replace with function body.


