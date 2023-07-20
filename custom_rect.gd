extends TextureRect
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#
#var pressed: bool = false
#var drag_pos_start
#func _gui_input(event):
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
#		if event.pressed:
#			if abs(event.position.x - position.x) < 50:
#				pressed = true
##				print("DRAG STARTED")
#				drag_pos_start = event.position
#		else:
#			print(abs(event.position.x	 - position.x))
#			pressed = false
##			print("DRAG ENDED")
#	if event is InputEventMouseMotion and pressed:
#
#		position.x = (drag_pos_start.x)
#
#
#		drag_pos_start = event.position
#
#	if position.x < 0:
#		position.x = 0
#	if position.x > get_parent().size.x:
#		position.x = get_parent().size.x
#
