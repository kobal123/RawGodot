extends VBoxContainer
signal index_changed_for_effect(old_index, new_index)
var scene_res: PackedScene = preload("res://editor_piece.tscn")
var foldable = preload("res://Foldable.tscn")


var channel_mixer_scene = preload("res://channel_mixer_component.tscn")
var foldable_item_scene = preload("res://Foldable_item.tscn")
var histogram_scene = preload("res://histogram.tscn")
var edge_scene = preload("res://edge_control.tscn")

var checkbox_editor_piece = preload("res://custom_shader_checkbox.tscn")

var grayscale_effect_slider_scene = preload("res://custom_slider.tscn")


var created_effects: int = 0

var is_ready: bool = false




signal NODE_READY

# Called when the node enters the scene tree for the first time.
func _ready():

	ComputePipeLineManager.map_effect_buffer(0, ComputePipeLineManager.SHADER.BASIC, [], [1.0, 1.0, 1.0, 1.0])
	
	var scene = scene_res.instantiate()
	var scene2 = scene_res.instantiate()
	var scene3 = scene_res.instantiate()
	var scene4 = scene_res.instantiate()

	scene.setup("Brightness",-1.0,1.0,0.01,0.0)
	scene.set_id(str(get_child_count()))
	scene.set_value_changed_calls(0)
	scene.set_buffer_owner_id(0)
#	scene.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,0)
	


	scene3.setup("Contrast",0.1,2.0,0.01,1.0)

	scene3.set_id(str(get_child_count()))
#	ComputePipeLineManager.map_effect_buffer(2,[],[1.0])
	scene3.set_value_changed_calls(1)
	scene3.set_buffer_owner_id(0)
#	scene3.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,2)
#	add_child(scene3) 
	
	scene2.setup("Saturation",-3,3.0,0.01,1.0)
	scene2.set_id(str(get_child_count()))
#	ComputePipeLineManager.map_effect_buffer(1,[],[1.0])
	scene2.set_value_changed_calls(2)
#	add_child(scene2) 
	scene2.set_buffer_owner_id(0)
	
	var EV = scene_res.instantiate()
	EV.setup("Exposure",-3,3.0,0.01,1.0)
	EV.set_id(str(get_child_count()))
#	ComputePipeLineManager.map_effect_buffer(1,[],[1.0])
	EV.set_value_changed_calls(3)
#	add_child(scene2) 
	EV.set_buffer_owner_id(0)
	
#	var saturation_matrix = func(saturation: float):
#		const  rwgt = 0.3086;
#		const  gwgt = 0.6094;
#		const  bwgt = 0.0820;
#		var ret: PackedFloat32Array
#		var one_m_saturation = 1 - saturation
##		ret =  [one_m_saturation * rwgt + saturation, one_m_saturation * rwgt, one_m_saturation * rwgt, 0.0,
##		one_m_saturation * gwgt, one_m_saturation * gwgt + saturation, one_m_saturation * gwgt, 0.0,
##		one_m_saturation * bwgt, one_m_saturation * bwgt, one_m_saturation * bwgt + saturation, 0.0,
##		0.0, 0.0, 0.0, 1.0]
#
#		ret =  [one_m_saturation * rwgt + saturation, one_m_saturation * rwgt, one_m_saturation * rwgt, 0.0,
#		one_m_saturation * gwgt, one_m_saturation * gwgt + saturation, one_m_saturation * gwgt, 0.0,
#		one_m_saturation * bwgt, one_m_saturation * bwgt, one_m_saturation * bwgt + saturation, 0.0,
#		0.0, 0.0, 0.0, 1.0]
#		return ret
	
#	scene2.set_transformation_function(saturation_matrix)
	
#	scene2.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,1)
	
	
	scene4.setup("Sharpness",1.0,17.0,2.0,1.0)
	scene4.set_id(str(get_child_count()))
	#scene4.set_value_changed(3,)
	ComputePipeLineManager.map_effect_buffer(1, ComputePipeLineManager.SHADER.SHARPNESS, [0,0,0,0], [])
	scene4.set_value_changed_calls(0, true)
	scene4.set_buffer_owner_id(1)
#	scene4.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,1)

#	add_child(scene4) 
	var basic_effects_foldable = foldable_item_scene.instantiate()
	basic_effects_foldable.set_label("Basic effects")
	basic_effects_foldable.add_item(scene)
	basic_effects_foldable.add_item(scene2)
	basic_effects_foldable.add_item(scene3)
	basic_effects_foldable.add_item(EV)
#	basic_effects_foldable.add_item(scene4)
	basic_effects_foldable.checkbox_visible(true)
	basic_effects_foldable.toggle_items_visibility()
	basic_effects_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,0)

	add_element(basic_effects_foldable)


	var sharpening_foldable = foldable_item_scene.instantiate()
	sharpening_foldable.add_item(scene4)
	sharpening_foldable.checkbox_visible(true)
	sharpening_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,1)
	sharpening_foldable.set_label("Sharpening")
	add_element(sharpening_foldable)
	
	
	var channel_mixer_foldable = foldable_item_scene.instantiate()
	channel_mixer_foldable.set_label("Channel mixer")

	var mixer_components = create_channel_mixer()
	for component in mixer_components:
		channel_mixer_foldable.add_item(component)
	
	channel_mixer_foldable.checkbox_visible(true)
	channel_mixer_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,2)
	add_element(channel_mixer_foldable)
#	ComputePipeLineManager.map_effect_buffer(4,[],[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
#
	# we need this element as an invisible one,
	# since the negative thingy is just a toggle


	ComputePipeLineManager.map_effect_buffer(3,ComputePipeLineManager.SHADER.NEGATIVE,[],[0.0,0.0,0.0,0.0])
	var negative_invisible = scene_res.instantiate()
	negative_invisible.visible = false
	negative_invisible.set_buffer_owner_id(3)

	var negative_foldable = foldable_item_scene.instantiate()
	negative_foldable.set_label("Negative")
	negative_foldable.disable_arrow()
	negative_foldable.checkbox_visible(true)
	negative_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,3)
	negative_foldable.add_item(negative_invisible)
	add_element(negative_foldable)
	
	ComputePipeLineManager.map_effect_buffer(4,ComputePipeLineManager.SHADER.VIGNETTING ,[1],[0.0, 0.0, 0.0])
	var vignetting_foldable = foldable_item_scene.instantiate()
	vignetting_foldable.set_label("Vignetting")
	vignetting_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,4)
	vignetting_foldable.checkbox_visible(true)
	var vignetting_strength = scene_res.instantiate()
	vignetting_strength.setup("Strength",-100.0,100.0,1.0,1.0)
	vignetting_strength.set_id(str(get_child_count()))
	vignetting_strength.set_value_changed_calls(0, true)
	vignetting_strength.set_buffer_owner_id(4)
	
	var vignetting_radiusstart = scene_res.instantiate()
	vignetting_radiusstart.setup("Radius start",0.0,1.0,0.01,1.0)
	vignetting_radiusstart.set_id(str(get_child_count()))
	vignetting_radiusstart.set_value_changed_calls(1)
	vignetting_radiusstart.set_buffer_owner_id(4)

	var vignetting_radiusend = scene_res.instantiate()
	vignetting_radiusend.setup("Radius end",0.0,1.0,0.01,1.0)
	vignetting_radiusend.set_id(str(get_child_count()))
	vignetting_radiusend.set_value_changed_calls(2)
	vignetting_radiusend.set_buffer_owner_id(4)
	
	vignetting_foldable.add_item(vignetting_strength)
	vignetting_foldable.add_item(vignetting_radiusstart)
	vignetting_foldable.add_item(vignetting_radiusend)
	
	add_element(vignetting_foldable)
	
	#FOR GAUSS
	ComputePipeLineManager.map_effect_buffer(5, ComputePipeLineManager.SHADER.BLUR_HORIZONTAL, [0,1,1,1],[])
	ComputePipeLineManager.map_effect_buffer(6, ComputePipeLineManager.SHADER.BLUR_VERTICAL, [0,1,1,1],[])
	
	var blur_horizontal_invisible = scene_res.instantiate()
	blur_horizontal_invisible.visible = false
	blur_horizontal_invisible.set_buffer_owner_id(5)
	
	var blur_vertical_invisible = scene_res.instantiate()
	blur_vertical_invisible.visible = false
	blur_vertical_invisible.set_buffer_owner_id(6)
	

	var blur_disable_func = func():
		ComputePipeLineManager.swap_pipeline_availability_at_index(5,6)
#		ComputePipeLineManager.swap_pipeline_availability_at_index(6)	
	var blur_foldable = foldable_item_scene.instantiate()
	blur_foldable.set_checkbox_callback(blur_disable_func)
	blur_foldable.set_label("Blur")
	blur_foldable.disable_arrow()
	blur_foldable.checkbox_visible(true)
	blur_foldable.add_item(blur_horizontal_invisible)
	blur_foldable.add_item(blur_vertical_invisible)
	
	add_element(blur_foldable)


	ComputePipeLineManager.map_effect_buffer(7,ComputePipeLineManager.SHADER.INFRARED,[],[0.0,0.0,0.0,0.0])
	var infrared_invisible = scene_res.instantiate()
	infrared_invisible.visible = false
	infrared_invisible.set_buffer_owner_id(7)

	var infrared_foldable = foldable_item_scene.instantiate()
	infrared_foldable.set_label("Infrared")
	infrared_foldable.disable_arrow()
	infrared_foldable.checkbox_visible(true)
	infrared_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,7)
	infrared_foldable.add_item(infrared_invisible)
	add_element(infrared_foldable)
	
	
	ComputePipeLineManager.map_effect_buffer(8,ComputePipeLineManager.SHADER.GRAYSCALE, [], [0.6, 0.3, 0.1, 0.0])
	var grayscale_effect_slider = grayscale_effect_slider_scene.instantiate()
	grayscale_effect_slider.set_buffer_offset(0)
	grayscale_effect_slider.set_buffer_owner_id(8)
	
	var grayscale_foldable = foldable_item_scene.instantiate()
	grayscale_foldable.set_label("Grayscale")

	grayscale_foldable.checkbox_visible(true)
	grayscale_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,8)
	grayscale_foldable.add_item(grayscale_effect_slider)
	
	
	add_element(grayscale_foldable)
	
	
	
	

	
#	ComputePipeLineManager.map_effect_buffer(9, ComputePipeLineManager.SHADER.GAUSSIAN_SINGLE_PASS, [], [0.6, 0.3,0.3,0.3])
#
##	var bloom_threshold = scene_res.instantiate()
##	bloom_threshold.setup("Threshold", 0.0, 1.0,0.01, 0.5)
##	bloom_threshold.set_value_changed_calls(0)
##	bloom_threshold.set_buffer_owner_id(9)
##	var bloom_strength = scene_res.instantiate()
##	bloom_strength.setup("Strength", 0.0, 1.0,0.01, 0.5)
##	bloom_strength.set_value_changed_calls(1)
##	bloom_strength.set_buffer_owner_id(9)
#
#	var bloom_foldable = foldable_item_scene.instantiate()
#	bloom_foldable.set_label("Gauss blur")
#
#	bloom_foldable.checkbox_visible(true)
#	bloom_foldable.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,9)
##	bloom_foldable.add_item(bloom_threshold)
##	bloom_foldable.add_item(bloom_strength)
#
#
#
#	add_element(bloom_foldable)
	
	
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
	ComputePipeLineManager.map_effect_buffer(2, ComputePipeLineManager.SHADER.CHANNEL_MIXER,[],[1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0])
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
	return
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
#			print("index: ",_index_," child pos: ", c.position," mouse pos: ", _position)
			if data == c:
				_found_data_index = _index_
				
#			print(abs(c.position.y - _position.y))
			if abs(c.position.y + c.size.y - _position.y) < data.size.y:
				_closest_child_index =_index_
				
			_index_ += 1
		move_child(get_child(_found_data_index),_closest_child_index)
	return can_drop



func _drop_data(_position: Vector2, data) -> void:
	
	print("DROPPING DATA")
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
#	if _closest_child_index > get_child_count() -1:
#		_closest_child_index = get_child_count() -1;
#	move_child(get_child(_found_data_index), _closest_child_index)
	# we need the effect ID, and since the data object we get is the foldable,
	# we have to get the child of that. 
	var IDS := get_effect_ids(data)
	for index in len(IDS):
		ComputePipeLineManager.change_effect_order(IDS[index], _closest_child_index + index)
	print("CLOSEST INDEX: ", _closest_child_index)


func get_effect_ids(foldable_: Control) -> Array[int]:
	
	var IDS: Array[int] = []
	var foldable_children = foldable_.get_children_from_items()
	
	for c in foldable_children:
		if !IDS.has(c.BUFFER_OWNER_ID):
			IDS.push_back(c.BUFFER_OWNER_ID)
	
	print("RETURNING IDS: ", IDS)
	return IDS

var custom_panels: Array[Node] = []


func create_custom_effect_panel(shader_variables: Array[CustomShaderParser.SHADER_VARIABLE], rid: RID, index_:int):
	var custom_panel = null
#	if custom_panel != null:
#		remove_child(custom_panel)
#		custom_panel.queue_free()

	if index_ < custom_panels.size():
		print("FREEING CHILD, INDEX: ", index_)
		var c = custom_panels[index_]
		remove_child(c)
		c.queue_free()
		custom_panels.remove_at(index_)
	print("CREATING CUSTOM EFFECT, INDEX: ", index_)

	var int_buffer_values: PackedInt32Array = []
	var float_buffer_values: PackedFloat32Array = []
#	var bool_buffer_values: Array[int] = []
	var bool_buffer_values: PackedInt32Array = []
	for variable in shader_variables:
#		var variable: CustomShaderParser.SHADER_VARIABLE = shader_variables[key] 
		if variable._type_str == "int":
			int_buffer_values.push_back(variable.start_value)
		elif variable._type_str == "float":
			float_buffer_values.push_back(variable.start_value)
		else:
			bool_buffer_values.push_back(0)
	ComputePipeLineManager.create_custom_effect_buffer(index_, int_buffer_values, float_buffer_values, bool_buffer_values)
	ComputePipeLineManager.add_custom_effect_shader(index_, rid)
	custom_panel = foldable_item_scene.instantiate()
	
	var index = 0
	for variable in shader_variables:
		var custom_editor_piece# = scene_res.instantiate()
		if variable._type_str == "bool":
			custom_editor_piece = checkbox_editor_piece.instantiate()
		else:
			custom_editor_piece = scene_res.instantiate()
			custom_editor_piece.set_data_type(variable._type_str)
		custom_editor_piece.set_buffer_owner_id(index_)
		custom_editor_piece.set_value_changed_calls(index)


		var callback = func(_value, is_int: bool, is_bool, buf_id: int, update_pos: int):
			if is_int:
				var d: PackedInt32Array = [_value] 
				ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id,d.to_byte_array(), update_pos])
			elif is_bool:
				print("UPDATING BOOL VALUE IN CUSTOM EFFECT")
				print("BUF ID: ", buf_id)
				var buf_data: PackedByteArray = ComputePipeLineManager.get_custom_buffer(buf_id)
				
				print("BUFFER DATA BEFORE UPDATE: ", buf_data, ", update pos: ", update_pos)
				var value = buf_data.decode_s32(update_pos * 4)
				var new_buf:PackedInt32Array = [] 
				if value == 1:
					print("VALUE WAS 1")
					new_buf.push_back(0)
					
					ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id, new_buf.to_byte_array(), update_pos])
				else:
					print("VALUE WAS 0")
					new_buf.push_back(1)
					ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id, new_buf.to_byte_array(), update_pos])
#				if _value:
					#TODO: BIT SHIFTING KELL, MIVEL HIÁBA VAN 2 Bájt adat,
					# a 2 bool 1 bájton elfér.
#				ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id, buf_data, update_pos, true])
#				else:
#					buf_data[update_pos] = 0#buf_data[update_pos] << (update_pos + 1)
#					ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id, buf_data, update_pos, true])
#				buf_data = ComputePipeLineManager.get_custom_buffer(buf_id)
				print("BUFFER DATA AFTER UPDATE: ", buf_data, ", update pos: ", update_pos)
			else:
				var d: PackedFloat32Array = [_value] 
				ComputePipeLineManager.callv("update_custom_effect_buffer",[buf_id,d.to_byte_array(), update_pos])
			
		custom_editor_piece.set_value_changed_callback(callback)
		
		print("MIN: ", variable._min)
		print("MAX: ", variable._max)
		print("STEP: ", variable._step)
		if variable._type_str == "bool":
			custom_editor_piece.setup(variable._name, variable.bool_value)
		else:
			custom_editor_piece.setup(variable._name, variable._min, variable._max, variable._step, variable.start_value)
#		custom_editor_piece.setup(variable._name, variable._min, variable._max, variable._step, variable.start_value)
		index += 1
		custom_panel.add_item(custom_editor_piece)
		custom_panel.checkbox_visible(true)
#		custom_panel.set_checkbox_callback(ComputePipeLineManager.swap_pipeline_availability_at_index,8)
	
	custom_panel.set_label("Custom effect")
	add_element(custom_panel)
	custom_panels.insert(index_, custom_panel)



func compute_gaussian_kernel():
	var kernelSize = 9
	var sigma = 1.5

	# Calculate the weights for the kernel
	var weights = PackedFloat32Array()
	weights.resize(kernelSize * kernelSize)
	var sum = 0.0
	for i in range(kernelSize):
		for j in range(kernelSize):
			var x = float(i - (kernelSize - 1) / 2)
			var y = float(j - (kernelSize - 1) / 2)
			var weight = exp(-(x * x + y * y) / (2.0 * sigma * sigma))
			weights[i * kernelSize + j] = weight
			sum += weight

	# Normalize the weights
	for i in range(weights.size()):
		weights[i] /= sum


	
	
func create_buffer():
	pass
