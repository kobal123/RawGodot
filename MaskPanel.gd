extends VBoxContainer
signal index_changed_for_effect(old_index, new_index)
var scene_res: PackedScene = preload("res://mask_editor_piece.tscn")
var foldable = preload("res://Foldable.tscn")


var channel_mixer_scene = preload("res://channel_mixer_component.tscn")
var foldable_item_scene = preload("res://Foldable_item.tscn")
var histogram_scene = preload("res://histogram.tscn")
var edge_scene = preload("res://edge_control.tscn")


var created_effects: int = 0

var is_ready: bool = false

var mask_name: String = ""





# Called when the node enters the scene tree for the first time.
func setup(_name: String):
	mask_name = _name
	var basic_effect_id: int = ComputePipeLineManager.create_mask_effect_buffer(_name, [],[1.0, 1.0, 1.0, 1.0])

	
	var _brightness = scene_res.instantiate()
	var _saturation = scene_res.instantiate()
	var _contrast = scene_res.instantiate()


	_brightness.setup("Brightness",-1.0,1.0,0.0001,0.0, _name)
	_brightness.set_id(str(get_child_count()))
	_brightness.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, basic_effect_id))
	_brightness.set_buffer_owner_id(basic_effect_id)

	_contrast.setup("Contrast",0.1,2.0,0.01,1.0 , _name)
	_contrast.set_id(str(get_child_count()))
	_contrast.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, basic_effect_id))
	_contrast.set_buffer_owner_id(basic_effect_id)

	_saturation.setup("Saturation",-3,3.0,0.01,1.0, _name)
	_saturation.set_id(str(get_child_count()))
	_saturation.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, basic_effect_id))
	_saturation.set_buffer_owner_id(basic_effect_id)
	
	var EV = scene_res.instantiate()
	EV.setup("Exposure",-3,3.0,0.01,1.0, _name)
	EV.set_id(str(get_child_count()))
	EV.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, basic_effect_id))
	EV.set_buffer_owner_id(basic_effect_id)

	

#	add_child(scene4) 
	var basic_effects_foldable = foldable_item_scene.instantiate()
	basic_effects_foldable.set_label("Basic effects")
	basic_effects_foldable.add_item(_brightness)
	basic_effects_foldable.add_item(_saturation)
	basic_effects_foldable.add_item(_contrast)
	basic_effects_foldable.add_item(EV)

	basic_effects_foldable.checkbox_visible(true)
	basic_effects_foldable.toggle_items_visibility()
	basic_effects_foldable.set_checkbox_callback(ComputePipeLineManager.disable_mask_effect, [_name, basic_effect_id])

	add_element(basic_effects_foldable)


	var negative_effect_id: int = ComputePipeLineManager.create_mask_effect_buffer(_name, [1],[])
	var negative_foldable = foldable_item_scene.instantiate()
	negative_foldable.set_label("Negative")
	negative_foldable.set_checkbox_callback(ComputePipeLineManager.disable_mask_effect, [_name, negative_effect_id])
	negative_foldable.checkbox_visible(true)
	add_element(negative_foldable)



	
	
	var sharpening_effect_id: int = ComputePipeLineManager.create_mask_effect_buffer(_name, [1],[])
#	var _sharpening_kernel = scene_res.instantiate()
#	_sharpening_kernel.setup("Kernel",0,9 , 0, 0.01, _name)
#	_sharpening_kernel.set_id(str(get_child_count()))
#	_sharpening_kernel.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, sharpening_effect_id))
#	_sharpening_kernel.set_buffer_owner_id(sharpening_effect_id)

#	var _sharpening_threshold = scene_res.instantiate()
#	_sharpening_threshold.setup("threshold",0,9 , 0, 0.01, _name)
#	_sharpening_threshold.set_id(str(get_child_count()))
#	_sharpening_threshold.set_buffer_offset(ComputePipeLineManager.mask_buffer_next_offset(_name, sharpening_effect_id))
#	_sharpening_threshold.set_buffer_owner_id(sharpening_effect_id)

	var sharpening_foldable = foldable_item_scene.instantiate()
#	sharpening_foldable.add_item(_sharpening_kernel)
#	sharpening_foldable.add_item(_sharpening_threshold)
	sharpening_foldable.set_label("Infrared")
	sharpening_foldable.set_checkbox_callback(ComputePipeLineManager.disable_mask_effect, [_name, sharpening_effect_id])
	sharpening_foldable.checkbox_visible(true)
	add_element(sharpening_foldable)
	


	return

#	var _sharpness = scene_res.instantiate()
#
#	_sharpness.setup("Sharpness",1.0,9.0,2.0,1.0)
#	_sharpness.set_id(str(get_child_count()))
#	#scene4.set_value_changed(3,)
#	ComputePipeLineManager.map_effect_buffer(1,[0],[])
#	_sharpness.set_value_changed_calls(0, true)
#	_sharpness.set_buffer_owner_id(1)
##	_sharpness.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,1)
#
#
#	var sharpness_foldable = foldable_item_scene.instantiate()
#	sharpness_foldable.add_item(_sharpness)
#	sharpness_foldable.checkbox_visible(true)
#	sharpness_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,3)
#	sharpness_foldable.set_label("Sharpening")
#	add_element(sharpness_foldable)
#
#
#	var channel_mixer_foldable = foldable_item_scene.instantiate()
#	channel_mixer_foldable.set_label("Channel mixer")
#
#	var mixer_components = create_channel_mixer()
#	for component in mixer_components:
#		channel_mixer_foldable.add_item(component)
#
#	channel_mixer_foldable.checkbox_visible(true)
#	channel_mixer_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,2)
#	add_element(channel_mixer_foldable)
##	ComputePipeLineManager.map_effect_buffer(4,[],[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
##
#
#
#	ComputePipeLineManager.map_effect_buffer(3,[],[0.0])
#	var negative_foldable = foldable_item_scene.instantiate()
#	negative_foldable.set_label("Negative")
#	negative_foldable.disable_arrow()
#	negative_foldable.checkbox_visible(true)
#	negative_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,3)
#	add_element(negative_foldable)
#
#	ComputePipeLineManager.map_effect_buffer(4,[1],[0.0, 0.0])
#	var vignetting_foldable = foldable_item_scene.instantiate()
#	vignetting_foldable.set_label("Vignetting")
#	vignetting_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,4)
#	vignetting_foldable.checkbox_visible(true)
#	var vignetting_strength = scene_res.instantiate()
#	vignetting_strength.setup("Strength",-100.0,100.0,1.0,1.0)
#	vignetting_strength.set_id(str(get_child_count()))
#	vignetting_strength.set_value_changed_calls(0, true)
#	vignetting_strength.set_buffer_owner_id(4)
#
#	var vignetting_radiusstart = scene_res.instantiate()
#	vignetting_radiusstart.setup("Radius start",0.0,1.0,0.01,1.0)
#	vignetting_radiusstart.set_id(str(get_child_count()))
#	vignetting_radiusstart.set_value_changed_calls(1)
#	vignetting_radiusstart.set_buffer_owner_id(4)
#
#	var vignetting_radiusend = scene_res.instantiate()
#	vignetting_radiusend.setup("Radius end",0.0,1.0,0.01,1.0)
#	vignetting_radiusend.set_id(str(get_child_count()))
#	vignetting_radiusend.set_value_changed_calls(2)
#	vignetting_radiusend.set_buffer_owner_id(4)
#
#	vignetting_foldable.add_item(vignetting_strength)
#	vignetting_foldable.add_item(vignetting_radiusstart)
#	vignetting_foldable.add_item(vignetting_radiusend)
#
#	add_element(vignetting_foldable)
#
#	#FOR GAUSS
#	ComputePipeLineManager.map_effect_buffer(5,[1],[])
#	ComputePipeLineManager.map_effect_buffer(6,[1],[])
#
#	var blur_disable_func = func():
#		ComputePipeLineManager.swap_pipeline_availability_at_index(5)
#		ComputePipeLineManager.swap_pipeline_availability_at_index(6)	
#	var blur_foldable = foldable_item_scene.instantiate()
#	blur_foldable.set_checkbox_callback(blur_disable_func)
#	blur_foldable.set_label("Blur")
#	blur_foldable.checkbox_visible(true)
#	add_element(blur_foldable)

	
#	ComputePipeLineManager.map_effect_buffer(7,[0],[])
#	var edge_foldable = foldable_item_scene.instantiate()
#	edge_foldable.set_label("find edges")
#	edge_foldable.checkbox_visible(true)
#	edge_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,7)
#
#
#	var edge = edge_scene.instantiate()
#	edge.set_buffer_id(7)
#	edge_foldable.add_item(edge)
#	add_element(edge_foldable)

	is_ready = true
	emit_signal("NODE_READY")



#adds an element, and also adds a separator between them
func add_element(node: Control):
#	if get_child_count() > 1:
#		add_child(HSeparator.new())
	add_child(node)

func create_channel_mixer() -> Array[Control]:
#	ComputePipeLineManager.map_effect_buffer(2,[],[1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0])
	var nodes: Array[Control] = []
	
	var ind_ = 0
	for update_pos in range(0, 9, 3):
		var channel_mixer_component = channel_mixer_scene.instantiate()
		if ind_ == 0:
			channel_mixer_component.setup(2, update_pos, "Red channel", [1.0,0.0,0.0])
		elif ind_ == 1:
			channel_mixer_component.setup(2, update_pos, "Green channel", [0.0,1.0,0.0])
		elif ind_ == 2:
			channel_mixer_component.setup(2, update_pos, "Blue channel", [0.0,0.0,1.0])
		ind_ += 1
		nodes.push_back(channel_mixer_component)

	created_effects += 1
	return nodes



func create_effect_component(label: String, min, max, step, start, allocate_buffer:bool = false) -> Control:
	
#	ComputePipeLineManager.map_effect_buffer(created_effects,[],[1.0])
	created_effects += 1

	var scene = scene_res.instantiate()
	scene.setup(label, min, max, step, start)
	return scene





func _can_drop_data(_position: Vector2, data) -> bool:
	var can_drop = data is Node and data.is_in_group("FOLDABLE")

	if can_drop:
		var _index_ = 0
		var _found_data_index = 0
		var _closest_child_index = 0
		for c in get_children():
			print("index: ",_index_," child pos: ", c.position," mouse pos: ", _position)
			if data == c:
				_found_data_index = _index_
				
			print(abs(c.position.y - _position.y))
			if abs(c.position.y + c.size.y - _position.y) < data.size.y:
				_closest_child_index =_index_
				
			_index_ += 1
		move_child(get_child(_found_data_index),_closest_child_index)
	return can_drop



func _drop_data(_position: Vector2, data) -> void:
	

	var _index_ = 0
	var _found_data_index = 0
	var _closest_child_index = 0
	for c in get_children():
		if data == c:
			
#			print("FOUND CHILD")
			_found_data_index = _index_
#		print("index: ",_index_," child pos: ", c.position)

		if  abs(c.position.y + c.size.y - _position.y) < data.size.y:
			_closest_child_index =_index_
		_index_ += 1

	data.modulate.a = 1
#	print("DROPPED ELEMENT")
	if _closest_child_index > get_child_count() -1:
		_closest_child_index = get_child_count() -1;
	move_child(get_child(_found_data_index), _closest_child_index)
	print("CLOSEST INDEX: ", _closest_child_index)


