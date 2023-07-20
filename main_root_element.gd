
extends Control


var is_dragging: bool = false

var currently_dragged_item: Control

func set_currently_dragged_item(element: Control):
	currently_dragged_item = element
	is_dragging = true


func set_is_dragging(val: bool):
	is_dragging = val

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		if is_dragging:
			is_dragging = false
			currently_dragged_item.modulate.a = 1
			currently_dragged_item = null

var mask_manager: Control

func _ready():
	mask_manager = %MaskManager
	mask_manager.remove_from_group("FOLDABLE")
	mask_manager.add_to_group("MASK_MANAGER")
