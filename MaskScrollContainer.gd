extends ScrollContainer

var mask_panel = preload("res://mask_panel.tscn")

#number of created panels
var created_panels:int = -1

func _ready():
	MaskDrawingMaster.connect("create_mask_panel", Callable(self,"create_mask_panel"))
	pass



# each mask will be mapped to the amount of created panels
# genereate 1 panel for each mask,
# when changing mask editing, make every child not visible
# but the current one.
var panelMapper: Dictionary = {}


func make_mask_panel_visible(mask_name):
	for c in get_children():
		if c.mask_name == mask_name:
			c.visible = true
		else:
			c.visible = false


func create_mask_panel(_name: String):
	
	panelMapper[name] = created_panels
	var panel = mask_panel.instantiate()
	panel.setup(_name)
	add_child(panel)
	created_panels += 1
	for c in len(get_children()):
		if c == created_panels:
			continue
		get_child(c).visible = false
