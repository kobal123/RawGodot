extends TextureRect


var zoom = Vector2(1.0,1.0)

var target_zoom: float = 1.0
const MIN_ZOOM: float = 1.0
const MAX_ZOOM: float = 64.0
const ZOOM_INCREMENT: float = 0.5
const ZOOM_RATE: float = 16.0
var event_happened: bool = false
var originx = 0.0
var originy = 0.0
var thread;

@export var apply_effects_bool: bool = true

var atlasTexture = AtlasTexture.new()

var contr = preload("res://contrast.gdshader")
var sat = preload("res://saturation.gdshader")
var sharp = preload("res://sharpness.gdshader")
var mask_contrast = preload("res://MASK_CONTRAST.gdshader")
var texFetch = preload("res://tex_fetch.gdshader")

var is_drawing: bool = false

var test = Image.create(1,1,false,Image.FORMAT_RGBA8)
var test_texture = ImageTexture.create_from_image(test)

var viewports = []
var viewport_rects = []

var current_viewport = 1
var current_viewport_rect = 1

var vp: SubViewport
var ttt :TextureRect
var vp2: SubViewport  
var ttt2 :TextureRect 

var effect_order: Array[Effect] = []
var mask_effect_order: Array[Effect] = []

var current_texture: Texture

signal started_apply_effect
signal finished_apply_effect


var render_rect = Vector4()

var clipping_positions: PackedInt32Array = [0,0,0,0]
var clipping_positions_set: Array[bool] = [false,false,false,false]


var preload_image_path: String = "-1"

func set_preload_image_path(s: String):
	preload_image_path = s

class Effect:
	var shader:Shader
	var values:Dictionary
	var is_mask:bool
	var mask_name
	func _init(shader_: Shader, shader_param_value: Dictionary, mask_shader:bool =false, mask_name_:String = ""):
		
		self.shader = shader_
		self.values = shader_param_value
		if !mask_shader and mask_name != "":
			print("Cannot set name for non mask shader")
			return
		self.is_mask = mask_shader
		self.mask_name = mask_name_

	func set_val(shader_param:String, value:float):
		if !values.has(shader_param):
			print("Error setting shader param: ", shader_param)
		
		values[shader_param] = value
		



func _ready():
	ComputePipeLineManager.connect("update_finished_",Callable(self,"_update_mat"))

#	effect_order.push_back(Effect.new(contr,{"contrast":0.0}))
#	effect_order.push_back(Effect.new(sat,{"saturation":1.0}))
#	effect_order.push_back(Effect.new(bright_,{"brightness":1.0}))
#	effect_order.push_back(Effect.new(sharp,{"kernel":0.0}))

#	MaskDrawingMaster.connect("mask_was_created",Callable(self,"add_mask_effect"))
#	MaskDrawingMaster.connect("mask_drawing",Callable(self,"apply_effects"))
	
	var effect_panel = AppNodeConstants.get_right_side_panel()
	
	if preload_image_path != "-1":

		await effect_panel.NODE_READY
		_on_file_dialog_file_selected(preload_image_path)
	clipping_positions = [0,0,0,0]

#func add_mask_effect(name_:String):
#	effect_order.push_back(Effect.new(mask_contrast,{"contrast":1.5},true, name_))
#	print("ADDED MASK EFFECT")
#	apply_effects()
	

func gui_input(event):
	get_parent()._input(event)
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position += event.relative * (Vector2.ONE/zoom)	
			originx += event.relative.x * (Vector2.ONE.x/zoom.x)
			originy += event.relative.y * (Vector2.ONE.y/zoom.y)
			get_local_mouse_position()

			
			event_happened = true
#			print("move: ",global_position)
#			print("move: ",position)
#			print("move: ",get_global_rect())
			emit_signal("resized")
			_on_resized()
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				event_happened = true
				target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
				var mouse_x = event.position.x - originx
				var mouse_y = event.position.y - originy
				var lastzoom = zoom;
				zoom = lerp(zoom, target_zoom * Vector2.ONE, ZOOM_RATE*0.07)
				scale = zoom
				var newx = mouse_x * (zoom/lastzoom);
				var newy = mouse_y * (zoom/lastzoom);

				originx += mouse_x - newx.x;
				originy += mouse_y - newy.y;
				_process(0.0)
				_on_resized()
				emit_signal("resized")

			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				event_happened = true
				target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
				var mouse_x = event.position.x - originx
				var mouse_y = event.position.y - originy
				var lastzoom = zoom;
				zoom = lerp(zoom, target_zoom * Vector2.ONE, ZOOM_RATE*0.07)
				scale = zoom
				var newx = mouse_x * (zoom/lastzoom);
				var newy = mouse_y * (zoom/lastzoom);

				originx += mouse_x - newx.x;
				originy += mouse_y - newy.y;
				_process(0.0)
				_on_resized()
				emit_signal("resized")

func _process(_delta):
	if(event_happened):
		position.x = originx
		position.y = originy
		event_happened = false
#		print("process: ", get_parent_area_size())
#		print("process: ",global_position)
#		print("process: ",position)
#		print("process scale: ", scale)
#		print("process: ",get_global_rect())
#		print("process:", get_viewport_rect())
#		print("process:", get_rect())

	

func _update_mat():
#	print("UPDATED TEXTURE")
	texture = ComputePipeLineManager.get_current_texture()

func load_image(path: String) -> void:
	_on_file_dialog_file_selected(path)

func _on_file_dialog_file_selected(path):
	ComputePipeLineManager.load_16_bit()
#	ComputePipeLineManager.load_32_bit()

	print("FILE PATH: ", path)
	var s = Time.get_ticks_msec()
	var image = Image.new()
	image.load(path)

	ComputePipeLineManager.set_base_texture(image)
	ComputePipeLineManager.setup()
	ComputePipeLineManager.apply_effects()
	_update_mat()
	var e = Time.get_ticks_msec()
	print("time taken: " , e-s,"ms")

	MaskDrawingMaster.set_texture_size(image.get_width(), image.get_height())
	MaskDrawingMaster.setup_mask_base()


	
func _on_grayscale_button_pressed():
	if self.material.shader == null:
		self.material.shader = null
	else:
		self.material.shader = null
		


func _on_apply_shader_button_pressed():
	
	if self.material.shader == texFetch:
		var s = %ShaderEdit
		var shader = Shader.new()
		shader.code = s.text
		var splits = s.text.split("\n")
		for line in splits:
			if line.contains("hint_range"):
				print(line)

		self.material.shader = shader
	else:
		self.material.shader = texFetch

	print("set shader")




#func _setBrightness(_value, _group):
##	return
#	ComputePipeLineManager.update_buffer(2,_value)
#	ComputePipeLineManager.apply_effects()
##	effect_order[2].set_val("brightness",_value)
##	apply_effects()
#
#func _setContrast(_value,_group):
##	effect_order[0].set_val("contrast",_value)
##	await apply_effects()
##	return
#	ComputePipeLineManager.update_buffer(0,_value)
#	ComputePipeLineManager.apply_effects()
#
#func _setSaturation(_value, _group):
#
##	effect_order[1].set_val("saturation",_value)
##	apply_effects()
##	return
#	ComputePipeLineManager.update_buffer(1,_value)
#	ComputePipeLineManager.apply_effects()
#
#func _setSharpness(_value, _group):
##	return
#	ComputePipeLineManager.update_buffer(3,_value)
#	ComputePipeLineManager.apply_effects()
#
#
#





func _on_resized():
	
	if texture == null:
		return

	var texture_width
	var texture_height
	var asp_ratio = float(texture.get_width())/float(texture.get_height())
	
	var tex_width = texture.get_width() * size.y / texture.get_height();
	var tex_height = size.y;

	if tex_width > size.x:
		tex_width = size.x;
		tex_height = texture.get_height() * size.x / texture.get_width();



	var offset_x = (size.x - tex_width) / 2;
	var offset_y = (size.y - tex_height) / 2;

#	size.width = tex_width;
#	size.height = tex_height;





#	if get_size().y < get_size().x:
	texture_width = scale.x * get_size().y * asp_ratio
	texture_height = scale.y * get_size().y
#		print("HEIGHT IS SMALLER THAN ")
#	else:
##		print("WIDTH IS SMALLER THAN HEIGHT")
#		texture_width = scale.x * get_size().y
#		texture_height = scale.y * get_size().y  * asp_ratio



	var left_padding_ = ((scale.x * get_size().x - texture_width) / 2.0 )
#	var top_padding = ((scale.x * get_size().y - texture_height) / 2.0) 
	var parent_size = get_parent().get_size()
	var width_ratio = texture_width/texture.get_width()
	var height_ratio = texture_height/texture.get_height()
	
#	if left_padding_<0:
##		texture_width =  scale.y * get_size().y
#		texture_height = scale.x * size.y / asp_ratio;
		
	var top_padding = ((scale.x * get_size().y - texture_height) / 2.0) 
	if left_padding_ < 0:
		texture_width += left_padding_ * 2

	clipping_positions[0] = 0
	clipping_positions[1] = 0
	clipping_positions[2] = 0
	clipping_positions[3] = 0
#	print("OFFSET Y: ", offset_y)
#	print("TOP PADDING: ", top_padding)
#	print("LEFT PADDING: ", left_padding_," offsetx: ", offset_x)
#	print("TEX WIDTH: ", tex_width, " TEXTURE_WIDTH: ", texture_width)
#	print("TEX HEIGHT: ", tex_height, " TEXTURE_HEIGHT: ", texture_height)
	
#	print("HEIGHT: ", size.y * asp_ratio, "   SIZE.Y: ", size.y)
	
	
#	if left_padding_ < 0:
	AppNodeConstants.get_mask_overlay().set_position(Vector2(offset_x + global_position.x,global_position.y + offset_y))
	AppNodeConstants.get_mask_overlay().set_size(Vector2(tex_width, tex_height))
	AppNodeConstants.get_mask_overlay().set_scale(scale)
	
	
	
	AppNodeConstants.get_clip_drawing_overlay().set_position(Vector2( offset_x + global_position.x,global_position.y + offset_y))
	AppNodeConstants.get_clip_drawing_overlay().set_size(Vector2(tex_width, tex_height))
#	AppNodeConstants.get_clip_drawing_overlay().set_scale(scale)


#	else:
#		AppNodeConstants.get_mask_overlay().set_position(Vector2(left_padding_ + global_position.x,global_position.y))
#		AppNodeConstants.get_mask_overlay().set_size(Vector2(tex_width, tex_height))
#
#
#		AppNodeConstants.get_mask_drawing_overlay().set_position(Vector2(left_padding_ + global_position.x,global_position.y))
#		AppNodeConstants.get_mask_drawing_overlay().set_size(Vector2(tex_width, tex_height))
	


func _on_right_side_panel_index_changed_for_effect(old_index, new_index):
	var child_ = get_child(old_index)
	move_child(child_,new_index)

	
