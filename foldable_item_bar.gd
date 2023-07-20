extends HBoxContainer

var arrow_right = preload("res://lil_arrow.png")
var arrow_down = preload("res://lil_arrow_down.png")


func _gui_input(event):

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				toggle_items_visibility()


func items_visible(vis: bool):
	if owner.arrow_disabled:
		return
	if vis:
		%items.show()
		%TextureRect.texture = arrow_down
	else:
		%items.hide()
		%TextureRect.texture = arrow_right


func toggle_items_visibility():
	if owner.arrow_disabled:
		return
	if !%items.visible:
		%items.show()
		%TextureRect.texture = arrow_down
	else:
		%items.hide()
		%TextureRect.texture = arrow_right
