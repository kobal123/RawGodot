extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func get_image_node() -> Control:
	return get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/Control2/myImageNode")

func get_right_side_panel() -> Control:
	return get_node("/root/Control/HSplitContainer/Panel/VBoxContainer/ScrollContainer/rightSidePanel")

func get_file_system_node() -> Control:
	return get_node("/root/Control/HSplitContainer/VSplitContainer/Panel/FileSystemTree")

func get_histogram_node() -> Control:
	return get_node("/root/Control/HSplitContainer/Panel/ScrollContainer/rightSidePanel/HBoxContainer").get_child_from_items(0)

func get_mask_scroll_container() -> Control:
	return get_node("/root/Control/HSplitContainer/Panel/VBoxContainer/MaskScrollContainer")



func get_root() -> Control:
	return get_node("/root/Control")
	
func get_mask_overlay() -> Control:
	return get_node("/root/Control/MaskDrawOverlay")


func get_clip_drawing_overlay() -> Control:
	return get_node("/root/Control/ClipDrawing")

func get_mask_manager() -> Control:
#	return get_node("/root/Control/MaskManager")
	return get_node("/root/Control/HSplitContainer/Panel/VBoxContainer/MaskManager").get_child_from_items(0)


func get_mask() -> Control:
	return get_image_node().get_child(0)
