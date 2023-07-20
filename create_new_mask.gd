extends Button

#signal create_mask_signal;


var mask_item_scene:PackedScene = preload("res://mask_item_scene.tscn")
var mask_item_container

var name_

var scene_

# Called when the node enters the scene tree for the first time.
func _ready():
	var imgNode = get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/Control2/myImageNode")
	connect("pressed",Callable(MaskDrawingMaster,"create_mask"))
	
	MaskDrawingMaster.connect("mask_was_created",Callable(self,"t"))
	mask_item_container = %MaskItemContainer
	#imgNode.connect("started_apply_effect",Callable(self,"detach_texture"))

	#imgNode.connect("finished_apply_effect",Callable(self,"attach_texture"))




func detach_texture():
	if scene_:
		scene_.detach_texture()

func attach_texture():
	if scene_:
		scene_.attach_texture(name_)


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func t(name:String):
	print(name)
	var scene = mask_item_scene.instantiate()
	scene.set_mask_preview_texture(MaskDrawingMaster.get_overlay_texture_by_name(name))
	scene.set_mask_preview_label(name)
	mask_item_container.add_child(scene)
	MaskDrawingMaster.set_current_mask(name)
	MaskDrawingMaster.switch_editable()
	name_ = name
	scene_ = scene
	ComputePipeLineManager.mask_setup()

	for child in mask_item_container.get_children():
		for child2 in mask_item_container.get_children():
			if !child.is_connected("item_clicked", Callable(child2, "item_was_clicked")):
				child.connect("item_clicked", Callable(child2, "item_was_clicked"))
			
		
		
