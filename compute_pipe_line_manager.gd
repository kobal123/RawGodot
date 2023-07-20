extends Node


######

#COMPUTE PIPELINE Master

######


enum SHADER {
	BASIC = 0,
	SHARPNESS = 1,
	CHANNEL_MIXER = 2,
	NEGATIVE = 3,
	VIGNETTING = 4,
	BLUR_HORIZONTAL = 5,
	BLUR_VERTICAL = 6,
	INFRARED = 7,
	GRAYSCALE = 8
#	GAUSSIAN_SINGLE_PASS = 9
}

var SHADER_NAMES = [
	"BASIC",
	"SHARPNESS",
	"CHANNEL_MIXER",
	"NEGATIVE",
	"VIGNETTING",
	"BLUR_HORIZONTAL",
	"BLUR_VERTICAL",
	"INFRARED",
	"GRAYSCALE"
#	"GAUSSIAN_SINGLE_PASS"
]

enum BUFFER_TYPE{
	INT,
	FLOAT
}


# if the clip tool is being used, return the base texture
var is_clipping: bool = false

func clipping_started():
	is_clipping = true
	emit_signal("update_finished_")

func clipping_finished():
	is_clipping = false
	emit_signal("update_finished_")


#var thread = Thread.new()
#var thread2 = Thread.new()


# map each effect index to another index
# indicating which shader to use to
# construct the pipeline
var effect_order_mapper: Array[int] = []


var rd_textures: Array[RID] = []
var applying_effects:bool = false

var is_setup: bool = false
var gpu: RenderingDevice
var shader: RID

signal update_finished_
signal update_histo(data:PackedInt32Array)

var usage = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT\
	| RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

#Contains the buffer IDs for the shaders used by the RenderingDevice
var buffers: Array[RID] = []


var HISTOGRAM_BUFFER: PackedInt32Array
var HISTOGRAM_BUFFER_ALL_ZERO: PackedInt32Array
var HISTOGRAM_BUFFER_RID: RID
var HISTOGRAM_ACCUMULATOR_BUFFER_RID: RID

# These go hand in hand, their sizes should be equal
# the uniform set at index X goes to the pipeline at index X
var uniformSets: Array[RID] = []
var pipelines: Array[RID] = []

var disabled_pipelines: Array[int] = []

# Array of textures used for ping-pong rendering
var textures: Array[ImageTexture] = []

var shaders: Array[RID] = []
# The base current texture, will be used as a base
# for the first pass of each rendering
var base_texture: ImageTexture


var current_texture: int = 0
var group_cnt: Vector2i

var clip_buffer_data: PackedInt32Array = []
var clip_buffer: RID

var buffer_input_bytes := PackedFloat32Array([1.0]).to_byte_array()


var img_size
var buffer_mapper: Array[BufferStruct]
var shader_mapper: Dictionary = {}



###################
	#HISTOGRAM
	
	
var HISTOGRAM_TEXTURE_RID: RID
var HISTOGRAM_TEXTURE: ImageTexture
var HISTOGRAM_HEIGHT: int = 128
var HISTOGRAM_WIDTH: int = 512
var HISTOGRAM_TEXTURE_UNIFROM: RID
var HISTOGRAM_TEXTURE_SHADER: RID
var HISTOGRAM_TEXTURE_PIPELINE: RID

var histogram_shaders: Array[RID] = []
var histogram_pipelines: Array[RID] = []
var histogram_uniforms: Array[RID] = []

###################

var histogram_enabled: bool = true
#var histogram_texture_rid: RID
#var histogram_texture: ImageTexture

func toggle_histogram():
	histogram_enabled = !histogram_enabled


var GAUSS_HORIZONTAL: int = -1
var GAUSS_VERTICAL: int = -1



##################################
#			   MASK
var mask_shaders: Array[RID] = []
var mask_uniform_sets: Array[RID] = []
var mask_pipelines: Array[RID] = []
var is_mask_setup: bool = false

enum MASK_SHADER {
	BASIC = 0,
	NEGATIVE = 1,
	SHARPENING = 2,
	LENGTH = 3
}

func disable_mask_effect(name_: String, buf_id: int):
	var mask_buf: MaskBuffer = mask_buffer_mapper[name_]
	mask_buf.toggle_buffer(buf_id)
	print("TOGGLED MASK EFFECT, NAME: ", name_, " ID: ", buf_id)
	recreate_pipelines_and_uniforms()
#	mask_setup()
#	apply_effects()


func mask_setup():

	if !is_mask_setup:
		create_mask_shaders()
#
#	swap_pipeline_availability_at_index(0)
#	swap_pipeline_availability_at_index(0)
	#load shader
	#create shader
	mask_uniform_sets.clear()
	for p in mask_pipelines:
		gpu.free_rid(p)
	mask_pipelines.clear()


	for mask_name in MaskDrawingMaster.get_mask_names():
		var mask_buf: MaskBuffer = mask_buffer_mapper[mask_name]
		for index in len(mask_buf.buffers):

			create_mask_uniforms(mask_name, index)

#	for index in len(mask_uniform_sets):
##		for k in len(mask_shaders):
#		print("CREATING MASK PIPELINE")
#		create_mask_pipeline(index)
		
	for mask_name in MaskDrawingMaster.get_mask_names():
		for index in MASK_SHADER.LENGTH:
			var mask_buf: MaskBuffer = mask_buffer_mapper[mask_name]
			if mask_buf.disabled_buffers.has(index):
				print("SKIPPING PIPELINE CREATION FOR MASK WITH NAME: ", mask_name, " WITH INDEX: ", index)
				continue
			create_mask_pipeline(index)
			pass
		
	is_mask_setup = true
	print("MASK SETUP")

func create_mask_shaders():
	var shader_spirv = load("res://mask/mask_brightness.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	mask_shaders.push_back(shader)
	shader_spirv = load("res://mask/mask_negative.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	mask_shaders.push_back(shader)
	shader_spirv = load("res://mask/mask_sharpening.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	mask_shaders.push_back(shader)


func create_mask_pipeline(index:int):
	var pipeline = gpu.compute_pipeline_create(mask_shaders[index % len(mask_shaders)])
	mask_pipelines.push_back(pipeline)

func create_mask_uniforms(_name: String, index: int):
	var mask_buf: MaskBuffer = mask_buffer_mapper[_name]
	if mask_buf.is_buffer_disabled(index):
		print("SKIPPING MASK UNIFORM CREATION FOR MASK: ", _name, " WITH INDEX: ", index)
		return
	print("CREATING MASK UNIFORM: ", _name, " WITH INDEX: ", index)
#	print("SOURCE CURRENT TEXTURE: ", current_texture)
	var source = RDUniform.new()
	source.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	source.binding = 0
	source.add_id(textures[current_texture].get_rd_texture_rid())
	
	current_texture = 1 - current_texture
#	print("TARGET CURRENT TEXTURE: ", current_texture)
	var target = RDUniform.new()
	target.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	target.binding = 1
	target.add_id(textures[current_texture].get_rd_texture_rid())



	var mask = RDUniform.new()
	mask.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	mask.binding = 2
	mask.add_id(MaskDrawingMaster.get_texture_by_name(_name).get_rd_texture_rid())
	

	var buffer = RDUniform.new()
	buffer.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	buffer.binding = 3
	buffer.add_id(mask_buf.buffers[index])
	

	var uniform_set_ = gpu.uniform_set_create([source, target, mask, buffer], mask_shaders[index], 0)
	mask_uniform_sets.push_back(uniform_set_)

func apply_mask_effects():
#	print("APPLYING MASK EFFECTS")
	for index in len(mask_pipelines):

		var cmd = gpu.compute_list_begin()
		gpu.compute_list_bind_compute_pipeline(cmd, mask_pipelines[index])
		gpu.compute_list_bind_uniform_set(cmd, mask_uniform_sets[index], 0)
		gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)

		gpu.compute_list_end()



##################################


class MaskBuffer:
	var disabled_buffers: Array[int] = []
	var total_buffers: int = -1
	var buffers: Array[RID] = []
	var buffer_offsets: Dictionary
	func add_buffer(id: RID) -> int:
		buffers.push_back(id)
		total_buffers += 1
		buffer_offsets[total_buffers] = -1
		return total_buffers
	
	func get_next_offset(buffer_id: int):
		var current_offset = buffer_offsets[buffer_id]
		current_offset += 1
		buffer_offsets[buffer_id] = current_offset
		return current_offset

	func toggle_buffer(buffer_id: int):
		if disabled_buffers.has(buffer_id):
			disabled_buffers.erase(buffer_id)
		else:
			disabled_buffers.push_back(buffer_id)

	func is_buffer_disabled(buffer_id: int) -> bool:
		return disabled_buffers.has(buffer_id)

class BufferStruct:
	var ID:int
	var shader_id: SHADER
	var buffer_id: RID
	func _init(id:int ,shader_id: SHADER, buf_id: RID):
		self.buffer_id = buf_id
		self.shader_id = shader_id
		self.ID = id
		
		



var total_effects: int = 0
var SHADER_LOCAL_SIZE_X = 32
var SHADER_LOCAL_SIZE_Y = 32
var HISTOGRAM_LOCAL_X = 64
var HISTOGRAM_LOCAL_Y = 1
var HISTOGRAM_DIM_X = 32
var HISTOGRAM_NUM_ELEMENTS = 2048 * HISTOGRAM_DIM_X
# Called when the node enters the scene tree for the first time.

var histogram_accumulator_buffer: PackedInt32Array = []
var accumulator_byte_arr: PackedByteArray 
func _ready():

	
	gpu = RenderingServer.get_rendering_device()
#	print("MAX SHARED MEMORY SIZE: ", gpu.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_SHARED_MEMORY_SIZE))
	HISTOGRAM_BUFFER.resize(HISTOGRAM_NUM_ELEMENTS)

	var byte_arr = HISTOGRAM_BUFFER.to_byte_array()
	HISTOGRAM_BUFFER_RID = gpu.storage_buffer_create(byte_arr.size(), byte_arr)
#	var histogram_accumulator_buffer: PackedInt32Array = []
	histogram_accumulator_buffer.resize(2048)
	accumulator_byte_arr = histogram_accumulator_buffer.to_byte_array()
	HISTOGRAM_ACCUMULATOR_BUFFER_RID = gpu.storage_buffer_create(accumulator_byte_arr.size(), accumulator_byte_arr)


	
	# Shaders should be preloaded since we use it for every draw no matter the image

	clip_buffer_data.resize(4)
	#TODO: base texturet átteni ebbe az arraybe, és 2ről indulni, aztán ping-pongozni.
	textures.resize(2)
	clip_buffer_data = [0,0,0,0]
	clip_buffer = gpu.storage_buffer_create(clip_buffer_data.to_byte_array().size(),clip_buffer_data.to_byte_array())
#	histogram_setup()

# (data[0], data[1]) = x,y pos of upper left position in crop rectangle
# (data[2], data[3]) = x,y pos of down right position in crop rectangle
func set_clip_buffer(clip_rect: Rect2i, kill_switch: int = 0) -> void:
	print("SET CLIP BUFFER")
	#update buffer and new size
	var buffer_data: PackedInt32Array = [clip_rect.position.x, clip_rect.position.y, 0, 0]
	var new_size = Vector2i(clip_rect.size.x, clip_rect.size.y)
	gpu.buffer_update(clip_buffer, 0, 16, buffer_data.to_byte_array(), RenderingDevice.BARRIER_MASK_COMPUTE)

	#update group count
	group_cnt = (new_size + Vector2i(SHADER_LOCAL_SIZE_X -1 , SHADER_LOCAL_SIZE_Y -1)) / Vector2i(SHADER_LOCAL_SIZE_X, SHADER_LOCAL_SIZE_Y)
	
	print("NEW SIZE: ", new_size)
	print("NEW BUFFER DATA: ", buffer_data)
	print("NEW GROUP COUNT: ", group_cnt)
	#resize textures used for ping pong
#	textures[0].set_size_override(new_size)
#	textures[1].set_size_override(new_size)
	var temp_image = Image.create(new_size.x, new_size.y, false, image_format)
	textures[0].set_image_with_usage(temp_image, usage)
	textures[1].set_image_with_usage(temp_image, usage)
	recreate_pipelines_and_uniforms()

func set_textures_(index: int, image: Image):
	textures[index] = ImageTexture.create_from_image_with_usage(image, usage)

func histogram_texture_setup():
	var form = RDTextureFormat.new()
	form.width = HISTOGRAM_WIDTH
	form.height = HISTOGRAM_HEIGHT
	form.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	form.usage_bits = usage | RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT

	var view = RDTextureView.new()
	view.format_override = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT

	HISTOGRAM_TEXTURE_RID = gpu.texture_create(form, view)
	HISTOGRAM_TEXTURE = ImageTexture.create_from_image_with_usage_empty(Image.FORMAT_RGBAF, HISTOGRAM_HEIGHT, HISTOGRAM_WIDTH, usage | RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT, HISTOGRAM_TEXTURE_RID)

func load_16_bit():
	RenderingServer.bits16()
	image_bit_format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
	image_format = Image.FORMAT_RGBAH

func load_32_bit():
	RenderingServer.bits32()
	image_bit_format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	image_format = Image.FORMAT_RGBAF

var image_bit_format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
var image_format = Image.FORMAT_RGBAF

func set_base_texture(image: Image):
	print("LOADED IMAGE FORMAT: ", image.get_format())
	var img_format = image.get_format()
#
#	if img_format == Image.FORMAT_RGBAH:
#		image_format = Image.FORMAT_RGBAH
#		image_format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
#	elif img_format == Image.FORMAT_RGB8:
#		image_format = Image.FORMAT_RGBA8
#		image_bit_format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
#		image.convert(image_format)
	image.convert(image_format)
	if is_setup:
		print("ALREADY SETUP!!!!!")

		var s = Time.get_ticks_msec()
		img_size = image.get_size()
		clean()
		rd_textures.resize(3)

		img_size = image.get_size()
		
		var ee = Time.get_ticks_msec()
		print("conversion took ", ee-s,"ms")
		group_cnt = (img_size + Vector2i(SHADER_LOCAL_SIZE_X - 1, SHADER_LOCAL_SIZE_Y - 1)) / Vector2i(SHADER_LOCAL_SIZE_X, SHADER_LOCAL_SIZE_Y)
		s = Time.get_ticks_msec()
		var form = RDTextureFormat.new()
		form.width = img_size.x
		form.height = img_size.y
		form.format = image_bit_format
		form.usage_bits = usage

		var view = RDTextureView.new()
		view.format_override = image_bit_format

		rd_textures[0] = gpu.texture_create(form,view)
		rd_textures[1] = gpu.texture_create(form,view)
		rd_textures[2] = gpu.texture_create(form,view)

		#base_texture = ImageTexture.create_from_image_with_usage(image,usage)
		#print("texutre foramt: ", base_texture.get_format())
		base_texture = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[0])
		textures[0] = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[1])
		textures[1] = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[2])
		var e = Time.get_ticks_msec()
		
		print("new texture creation took ", e-s,"ms")
#		print("created texture id: ", t)
#		print("created texture  RID: ", new_texture.get_rd_texture_rid())
		
		#var t2 = gpu.texture_create(form,view)
		#var t3 = gpu.texture_create(form,view)
		e = Time.get_ticks_msec()
		
		print("allocation took ", e-s,"ms")
		s = Time.get_ticks_msec()
		gpu.texture_update(rd_textures[0],0,image.get_data(),RenderingDevice.BARRIER_MASK_TRANSFER)
		e = Time.get_ticks_msec()
		print("update took ", e-s,"ms")

		print("texture size: ", base_texture.get_size())

		

		clean_uniforms(0)
		clean_pipelines(0)
		create_first_uniform_set(buffer_mapper[0].ID)
		var effect = buffer_mapper[0]
		
		create_pipeline(0)
#		print("all shaders: ", shaders)
		for i in range(1, len(shaders)):
			# we skip the first since we do that in create_first_uniform_set() 
#			print("setup shader: ", shaders[i])
			effect = buffer_mapper[i]
			create_uniform_set(effect.ID)
			create_pipeline(i)
		histogram_setup()
		apply_effects()
#		set_clip_buffer([0,0,0,0])


#		apply_effects()
	else:
		rd_textures.resize(3)
#		var s = Time.get_ticks_msec()
		img_size = image.get_size()
		
		var ee = Time.get_ticks_msec()
#		print("conversion took ", ee-s,"ms")
		group_cnt = (img_size + Vector2i(SHADER_LOCAL_SIZE_X - 1, SHADER_LOCAL_SIZE_Y - 1)) / Vector2i(SHADER_LOCAL_SIZE_X, SHADER_LOCAL_SIZE_Y)
#		s = Time.get_ticks_msec()
		var form = RDTextureFormat.new()
		form.width = img_size.x
		form.height = img_size.y
		form.format = image_bit_format
		form.usage_bits = usage

		var view = RDTextureView.new()
		view.format_override = image_bit_format

		rd_textures[0] = gpu.texture_create(form,view)
		rd_textures[1] = gpu.texture_create(form,view)
		rd_textures[2] = gpu.texture_create(form,view)

		#base_texture = ImageTexture.create_from_image_with_usage(image,usage)
		#print("texutre foramt: ", base_texture.get_format())
		base_texture = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[0])
		textures[0] = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[1])
		textures[1] = ImageTexture.create_from_image_with_usage_empty(image_format, img_size.y,img_size.x,usage,rd_textures[2])
#		var e = Time.get_ticks_msec()
		
#		print("new texture creation took ", e-s,"ms")
#		print("created texture id: ", t)
#		print("created texture  RID: ", new_texture.get_rd_texture_rid())
		
		#var t2 = gpu.texture_create(form,view)
		#var t3 = gpu.texture_create(form,view)
#		e = Time.get_ticks_msec()
		
#		print("allocation took ", e-s,"ms")
#		s = Time.get_ticks_msec()
		gpu.texture_update(rd_textures[0],0,image.get_data(),RenderingDevice.BARRIER_MASK_TRANSFER)
#		e = Time.get_ticks_msec()
#		print("update took ", e-s,"ms")

#		print("texture size: ", base_texture.get_size())


func recreate_pipelines_and_uniforms():
	GAUSS_HORIZONTAL = -1
	GAUSS_VERTICAL = -1
	current_texture = 0
	print("CURRENT ORDER: ")
	for index in len(effect_order_mapper):
		print(index,": ", effect_order_mapper[index])
	print("BUFFER ORDER: ")
	for index in len(buffer_mapper):
		print("index: ", index,": ID", buffer_mapper[index].ID," : ", SHADER_NAMES[buffer_mapper[index].shader_id])
	
	clean_uniforms(0)
	clean_pipelines(0)
	var effect = buffer_mapper[0]
	create_first_uniform_set(0)
	create_pipeline(0)
#		print("all shaders: ", shaders)
	for i in range(1, len(buffer_mapper)):
		# we skip the first since we do that in create_first_uniform_set() 
#			print("setup shader: ", shaders[i])
#		effect = buffer_mapper[i]
#		if disabled_pipelines.has(buffer_mapper[i].ID):
#			print("SKIPPED SHADER: ", SHADER_NAMES[buffer_mapper[i].shader_id])
#			continue
		create_uniform_set(i)
		create_pipeline(i)
	setup_custom_effects()
	mask_setup()
	histogram_setup()
	CodeEdit
#	apply_effects()
#	set_clip_buffer([0,0,0,0])
	
	apply_effects()
	apply_histo()

	
func get_current_texture() -> ImageTexture:
	if is_clipping:
		return base_texture
	
	if len(disabled_pipelines) == len(shaders):
		print("returning base texture")
		return base_texture
#	print("returning texture, disabled pipelines len: ", len(disabled_pipelines))
#	print("CURRENT TEXTURE: ", current_texture)
	return textures[current_texture]
	

func create_histogram_zero_uniform():
	print("CREATING HISTOGRAM ZERO UNIFORM SET: ")

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(HISTOGRAM_BUFFER_RID)

	var uniform_set_ = gpu.uniform_set_create([uniform], histogram_shaders[0], 0)
	histogram_uniforms.push_back(uniform_set_)


func create_histogram_uniform():
	print("CREATING HISTOGRAM UNIFORM SET: ")
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 0
	# if pipelines lenght is 2, then only the histograms are enabled
	if len(pipelines) == 1:
		print("USING BASE TEXTURE FOR HISTOGRAM UNIFORM")
		u0.add_id(base_texture.get_rd_texture_rid())
	else:
		u0.add_id(textures[current_texture].get_rd_texture_rid())
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 1 # this needs to match the "binding" in our shader file
	uniform.add_id(HISTOGRAM_BUFFER_RID)

	var uniform_set_ = gpu.uniform_set_create([u0,uniform], histogram_shaders[1], 0)
	histogram_uniforms.push_back(uniform_set_)

func create_shaders():
	# load shaders dynamically from resources?
	var s  = Time.get_ticks_msec()
	var shader_spirv = load("res://basic_effects.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	
	#TODO REMOVE THIS:

	
	
#	shader_spirv = load("res://fs_saturation.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)
#	shader_spirv = load("res://fs_contrast.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)
	shader_spirv = load("res://fs_sharpening.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	shader_spirv = load("res://fs_channel_mixer.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	shader_spirv = load("res://fs_negative.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	shader_spirv = load("res://fs_vignetting.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
#
	GAUSS_HORIZONTAL = len(shaders)
	shader_spirv = load("res://fs_gauss_horizontal.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	GAUSS_VERTICAL = len(shaders)
	shader_spirv = load("res://fs_gauss_vertical.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	shader_spirv = load("res://fs_infrared.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	shader_spirv = load("res://fs_grayscale.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	shaders.push_back(shader)
	
#
#	shader_spirv = load("res://fs_bloom_effect.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)

#	shader_spirv = load("res://single_pass_blur.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)
	


	shader_spirv = load("res://zero_histogram.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	histogram_shaders.push_back(shader)
	shader_spirv = load("res://histogram.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	histogram_shaders.push_back(shader)
	shader_spirv = load("res://histogram_accumulator.glsl").get_spirv()
	shader = gpu.shader_create_from_spirv(shader_spirv)
	histogram_shaders.push_back(shader)



	shader_spirv = load("res://histogram_texture.glsl").get_spirv()
	HISTOGRAM_TEXTURE_SHADER = gpu.shader_create_from_spirv(shader_spirv)
	
	
	var e  = Time.get_ticks_msec()
	
	print("loading shader took: ", e-s,"ms")

	
#creates the first uniform set
func create_first_uniform_set(ID: int):
	if disabled_pipelines.has(ID):
		print("SKIPPING UNIFORM ", 0)

		return
	
#	print("CREATING FIRST UNIFORM SET")
#	print("BUFFER MAPPER SIZE: ", buffer_mapper.size())
#	print("BUFFERS SIZE: ", buffers.size())
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 0
	u0.add_id(base_texture.get_rd_texture_rid())

	var u1 = RDUniform.new()
	u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u1.binding = 1
	u1.add_id(textures[current_texture].get_rd_texture_rid())
#	print("TARGET CURRENT TEXTURE: ", current_texture)
	# Create a uniform for the buffer to assign the buffer to the rendering device
#	var buffr = gpu.storage_buffer_create(buffer_input_bytes.size(),buffer_input_bytes)
#	buffers.push_back(buffr)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform.binding = 2 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer_mapper[0].buffer_id)
#	print("setting buf id: ", buffer_mapper[0].buffer_id)
#	uniform.add_id(buffr)
	
	var clip_ := RDUniform.new()
	clip_.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	clip_.binding = 3 # this needs to match the "binding" in our shader file
	clip_.add_id(clip_buffer)
	


	var uniform_set_ = gpu.uniform_set_create([u0,u1,uniform, clip_], shaders[buffer_mapper[0].shader_id], 0)
	print("CREATED FIRST UNIFORM FOR SHADER: ", SHADER_NAMES[buffer_mapper[0].shader_id])

	uniformSets.push_back(uniform_set_)
	
func create_uniform_set(index: int):
	if disabled_pipelines.has(buffer_mapper[index].ID):
		print("SKIPPING UNIFORM FOR SHADER: ", SHADER_NAMES[buffer_mapper[index].shader_id])

		return
#	print("CREATING UNIFORM SET: ", index)
#	print("SOURCE CURRENT TEXTURE: ", current_texture)
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 0
	u0.add_id(textures[current_texture].get_rd_texture_rid())
	
	current_texture = 1 - current_texture

#	print("TARGET CURRENT TEXTURE: ", current_texture)
	var u1 = RDUniform.new()
	u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u1.binding = 1
	u1.add_id(textures[current_texture].get_rd_texture_rid())

	# Create a uniform to assign the buffer to the rendering device
#	var buffr = gpu.storage_buffer_create(buffer_input_bytes.size(),buffer_input_bytes)
#	buffers.push_back(buffr)


	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform.binding = 2 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer_mapper[index].buffer_id)

#	uniform.add_id(buffr)
#	print("setting buf id: ", buffer_mapper[index].buffer_id)

#	var clip_ := RDUniform.new()
#	clip_.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
#	clip_.binding = 3 # this needs to match the "binding" in our shader file
#	clip_.add_id(clip_buffer)

	var uniform_set_ = gpu.uniform_set_create([u0,u1,uniform], shaders[buffer_mapper[index].shader_id], 0)
	if !gpu.uniform_set_is_valid(uniform_set_):
		print("ERROR IN UNIFORM SET")
		push_error("shader index: ", index, " shader name: ", SHADER_NAMES[buffer_mapper[index].shader_id])
	print("CREATED UNIFORM FOR SHADER: ", SHADER_NAMES[buffer_mapper[index].shader_id])
	uniformSets.push_back(uniform_set_)
	if buffer_mapper[index].shader_id == SHADER.BLUR_HORIZONTAL:
		GAUSS_HORIZONTAL = len(pipelines)
	elif buffer_mapper[index].shader_id == SHADER.BLUR_VERTICAL:
		GAUSS_VERTICAL = len(pipelines)

func apply_effects(_requesting_effect: int = 0):
	if applying_effects :
		return
	applying_effects = true
#	print("DATA BEFORE APPLY EFFECTS", HISTOGRAM_BUFFER.to_byte_array())
#	print("workgroup limit: ", gpu.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_INVOCATIONS))
#	var s = Time.get_ticks_usec()
#	print("NEW GROUP COUNT APPLY EFFECTS: ", group_cnt)
#	
	for index in len(pipelines):
	
		var cmd = gpu.compute_list_begin()
		gpu.compute_list_bind_compute_pipeline(cmd, pipelines[index])
		gpu.compute_list_bind_uniform_set(cmd, uniformSets[index], 0)
		
		
		#print("group count: ", group_cnt)
		if index  == GAUSS_HORIZONTAL:
#			print("GAUSS HORIZONTAL", index)
			var img_size_: PackedInt32Array = [img_size.x, img_size.y, 0, 0]
			var byte_arr = img_size_.to_byte_array()
			gpu.compute_list_set_push_constant(cmd, byte_arr, byte_arr.size())

			gpu.compute_list_dispatch(cmd, (img_size.x + 255) / 256, img_size.y, 1)
		elif index == GAUSS_VERTICAL:
#			print("GAUSS VERTICAL", index)
			var img_size_: PackedInt32Array = [img_size.x, img_size.y, 0, 0]
			var byte_arr = img_size_.to_byte_array()
			gpu.compute_list_set_push_constant(cmd, byte_arr, byte_arr.size())
			gpu.compute_list_dispatch(cmd, img_size.x, (img_size.y + 255 ) / 256, 1)
#		elif index == 3:
#			gpu.compute_list_dispatch(cmd, (img_size.x + 1) / 2, (img_size.y + 1) / 2, 1)
		else:
			gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)
#			gpu.compute_list_dispatch(cmd, (img_size.x + 63) / 64, (img_size.y + 7) / 8, 1)
#			print("DISPLAYED IMAGE SIZE: ", ((img_size.x + 63) / 64) * 8, " , ", ((img_size.y + 63) / 64) * 8)
#			print("ORIGINAL SIZE: ", img_size.x / ((img_size.x + 63) / 64) * 8)
#		gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)
		#gpu.compute_list_dispatch(cmd, 1, 1, 1)
		gpu.compute_list_end()
#		print(index)
#		print("GAUSS HOR: ", GAUSS_HORIZONTAL)
#		print("GAUSS VER: ", GAUSS_VERTICAL)
	apply_custom_effects()
	apply_mask_effects()
	apply_histo()
#	var e = Time.get_ticks_usec()
#	print("TIME TAKEN RENDERING: ", e-s)
#	print("LEN OF PIPELINES: ", len(pipelines))
	applying_effects = false
	emit_signal("update_finished_")

func apply_histo():
	if !histogram_enabled:
		return
		
	if HISTOGRAM_TEXTURE == null:
		print("HISTO TEXTURE IS NOT SET")
		return
#	gpu.texture_clear(HISTOGRAM_TEXTURE_RID, Color.BLACK, 0, 1, 0, 1)
#	print("CALLED HISTOGRAM")
	
	var cmd = gpu.compute_list_begin()
	gpu.compute_list_bind_compute_pipeline(cmd, histogram_pipelines[0])
	gpu.compute_list_bind_uniform_set(cmd, histogram_uniforms[0], 0)
	gpu.compute_list_dispatch(cmd, HISTOGRAM_NUM_ELEMENTS / 64, 1, 1)
	gpu.compute_list_end()




#	for i in range(2):
#		for k in range(2):
#			var offsets: PackedInt32Array = [k*((img_size.x + 1)/2), i*((img_size.y + 1)/2),0,0]
#			print("OFFSETS: ", offsets)
#			var poss:PackedInt32Array = [k*((img_size.x + 1)/2), i*((img_size.y + 1)/2)]
#			gpu.buffer_update(HISTOGRAM_BUFFER_RID, HISTOGRAM_NUM_ELEMENTS * 4, poss.size(), poss.to_byte_array())
#			var byte_array = offsets.to_byte_array()
#			cmd = gpu.compute_list_begin()
#			gpu.compute_list_bind_compute_pipeline(cmd, histogram_pipelines[1])
#			gpu.compute_list_set_push_constant(cmd, byte_array, byte_array.size())
#			gpu.compute_list_bind_uniform_set(cmd, histogram_uniforms[1], 0)
#			gpu.compute_list_dispatch(cmd, (img_size.x + 15) / 16, (img_size.y + 15) / 16, 1)
#			gpu.compute_list_end()

	cmd = gpu.compute_list_begin()
	gpu.compute_list_bind_compute_pipeline(cmd, histogram_pipelines[1])
	var img_size_: PackedInt32Array = [img_size.x, img_size.y, 0, 0]
	var byte_arr = img_size_.to_byte_array()
	gpu.compute_list_set_push_constant(cmd, byte_arr, byte_arr.size())

	gpu.compute_list_bind_uniform_set(cmd, histogram_uniforms[1], 0)
	gpu.compute_list_dispatch(cmd, (img_size.x + HISTOGRAM_LOCAL_X-1) / HISTOGRAM_LOCAL_X, (img_size.y + HISTOGRAM_LOCAL_Y - 1) / HISTOGRAM_LOCAL_Y, 1)
	gpu.compute_list_end()

	var s = Time.get_ticks_usec()
	gpu.buffer_update(HISTOGRAM_ACCUMULATOR_BUFFER_RID,0, accumulator_byte_arr.size(), accumulator_byte_arr)
	var e = Time.get_ticks_usec()
	print("UPDATE TOOK ", e-s ,"MS")
	cmd = gpu.compute_list_begin()
	gpu.compute_list_bind_compute_pipeline(cmd, histogram_pipelines[2])
	gpu.compute_list_bind_uniform_set(cmd, histogram_uniforms[2], 0)
	gpu.compute_list_dispatch(cmd, HISTOGRAM_DIM_X, 1, 1)
	gpu.compute_list_end()
#
#	cmd = gpu.compute_list_begin()
#	gpu.compute_list_bind_compute_pipeline(cmd, HISTOGRAM_TEXTURE_PIPELINE)
#	gpu.compute_list_bind_uniform_set(cmd, HISTOGRAM_TEXTURE_UNIFROM, 0)
#	gpu.compute_list_dispatch(cmd, (HISTOGRAM_WIDTH + 255) / 256, 1, 1)
#	gpu.compute_list_end()

	await RenderingServer.frame_post_draw
#	sum_(gpu.buffer_get_data(HISTOGRAM_BUFFER_RID))
	sum_(gpu.buffer_get_data(HISTOGRAM_ACCUMULATOR_BUFFER_RID))
	
#	gpu.buffer_clear(HISTOGRAM_BUFFER_RID,0,HISTOGRAM_BUFFER.to_byte_array().size(),RenderingDevice.BARRIER_MASK_COMPUTE)
func sum_(arr: PackedByteArray):
	var data: PackedInt32Array = []
	
	
	var dec_start = Time.get_ticks_msec()
	for i in range(2048):
		var num = arr.decode_s32(i*4)
		data.push_back(num)
	var dec_end = Time.get_ticks_msec()
	print("DECODING TOOK ", dec_end - dec_start, "ms")
#
#	print("DATA SIZE: ", data.size())
#	print("BYTES SIZE: ", arr.size())
	var d_sum = 0
	for d in data:
		d_sum += d
	print("SUM: ", d_sum, ", EXPECTED SUM: ", img_size.x * img_size.y * 4)
	if d_sum > img_size.x * img_size.y * 4:
		print("THERE ARE MORE HISTOGRAM DATA THAN SHOULD BE, SUM DIFF:", d_sum - img_size.x * img_size.y * 4)
	elif  d_sum < img_size.x * img_size.y * 4:
		print("THERE ARE LESS HISTOGRAM DATA THAN SHOULD BE, SUM DIFF:", d_sum - img_size.x * img_size.y * 4)
#
#
#	print("CALCULATED PART OF IMAGE: ", (img_size.x * img_size.y * 3) / d_sum)
	emit_signal("update_histo", data)

func set_histogram_data(data:PackedInt32Array):
	AppNodeConstants.get_histogram_node().set_data(data)

func create_pipeline(index: int):
	if disabled_pipelines.has(buffer_mapper[index].ID):
		print("SKIPPING PIPELINE CREATION, ID", index,", ORDER: ", effect_order_mapper.find(index)," SHADER: ",SHADER_NAMES[buffer_mapper[index].shader_id])
		return
#	print("CREATING PIPELINE, ID", index," ORDER: ", effect_order_mapper.find(index))
	var pipeline = gpu.compute_pipeline_create(shaders[buffer_mapper[index].shader_id])
	print("CREATED PIPELINE FOR SHADER: ", SHADER_NAMES[buffer_mapper[index].shader_id])
	pipelines.push_back(pipeline)


# ha arraykétn akarok átadni 2 intet, akkor nem hívja meg a függvényt,
# ha kikapcsolok egy effektet???
func swap_pipeline_availability_at_index(index: int, index2: int = -1 ):
	if disabled_pipelines.has(index):
#		print("ENABLED PIPELINE AT: ", effect_order_mapper.find(index))
		disabled_pipelines.remove_at(disabled_pipelines.find(index))
	else:
		print("DISABLED PIPELINE AT: ", effect_order_mapper.find(index))
		disabled_pipelines.push_back(index)

	if index2 != -1:
		if disabled_pipelines.has(index2):
			print("ENABLED PIPELINE AT: ", index2)
			disabled_pipelines.remove_at(disabled_pipelines.find(index2))
		else:
			print("DISABLED PIPELINE AT: ", index2)
			disabled_pipelines.push_back(index2)


	
	current_texture = 0
#	clean_uniforms(0)
#	clean_pipelines(0)
#
#	create_first_uniform_set()
#	create_pipeline(0)
##	print("all shaders: ", shaders)
#	for i in range(1, len(shaders)):
#		# we skip the first since we do that in create_first_uniform_set() 
##		print("setup shader: ", shaders[i])
#		create_uniform_set(i)
#		create_pipeline(i)
#
#	mask_setup()
#	histogram_setup()
#	create_histogram_zero_uniform()
#	create_pipeline(len(shaders)-2)
#	create_histogram_uniform()
#	create_pipeline(len(shaders)-1)
#
	recreate_pipelines_and_uniforms()
	
#	apply_effects()
#	apply_histo()

func create_histogram_accumulator_uniform():

	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	u0.binding = 0
	u0.add_id(HISTOGRAM_BUFFER_RID)


	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 1 # this needs to match the "binding" in our shader file
	uniform.add_id(HISTOGRAM_ACCUMULATOR_BUFFER_RID)

	var uniform_set_ = gpu.uniform_set_create([u0,uniform], histogram_shaders[2], 0)
	histogram_uniforms.push_back(uniform_set_)

func histogram_setup():
	for p in histogram_pipelines:
		gpu.free_rid(p)
	histogram_pipelines.clear()
	histogram_uniforms.clear()
	create_histogram_zero_uniform()
	create_histogram_uniform()
	create_histogram_accumulator_uniform()
	create_histogram_pipelines()
#	current_texture = 0
#	clean_uniforms(index-1)
#
#
#	print("all shaders: ", shaders)
#	for i in range(index-1, len(shaders)-2):
#		# we skip the first since we do that in create_first_uniform_set() 
#		print("setup shader: ", shaders[i])
#		create_uniform_set(i)
#	create_histogram_zero_uniform()
#	create_histogram_uniform()
#	apply_effects() 

func create_histogram_pipelines():
	histogram_pipelines.push_back(gpu.compute_pipeline_create(histogram_shaders[0]))
	histogram_pipelines.push_back(gpu.compute_pipeline_create(histogram_shaders[1]))
	histogram_pipelines.push_back(gpu.compute_pipeline_create(histogram_shaders[2]))
	

func clean_pipelines(from: int = 0):
	for i in range(from, len(pipelines)):
		gpu.free_rid(pipelines[i])
	pipelines.resize(from)

func setup():
	if is_setup:
		return
	#load shader
	#create shader
	create_shaders()
	histogram_texture_setup()
	create_histogram_texture_uniform()
	create_histogram_texture_pipeline()
#	create_first_uniform_set()
#	create_pipeline(0)
#
##	print("all shaders: ", shaders)
#	for index in range(1, len(shaders)):
#		# we skip the first since we do that in create_first_uniform_set() 
##		print("setup shader: ", shaders[index])
#		create_uniform_set(index)
#		create_pipeline(index)
#
#	histogram_setup()
	recreate_pipelines_and_uniforms()
	is_setup = true


func create_histogram_texture_uniform():
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 0
	u0.add_id(HISTOGRAM_TEXTURE.get_rd_texture_rid())
	
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 1
	uniform.add_id(HISTOGRAM_BUFFER_RID)

	HISTOGRAM_TEXTURE_UNIFROM = gpu.uniform_set_create([u0,uniform], HISTOGRAM_TEXTURE_SHADER, 0)
	
	
func create_histogram_texture_pipeline():
	HISTOGRAM_TEXTURE_PIPELINE = gpu.compute_pipeline_create(HISTOGRAM_TEXTURE_SHADER)

func update_buffer(_index: int, _value: float):
	pass
#	return
##	print("updating buffer: ", index)
#	gpu.buffer_update(buffers[index],0,buffer_input_bytes.size(), PackedFloat32Array([value]).to_byte_array(),RenderingDevice.BARRIER_MASK_COMPUTE)
#	print("OLD BUFER UPDATE")

#destroy every buffer, texture, etc..
func clean():

	for buff in buffers:
		gpu.free_rid(buff)
	buffers.clear()
		
	for t in textures:
		gpu.free_rid(t)
	gpu.free_rid(base_texture)
	for uni in uniformSets:
		gpu.free_rid(uni)
	uniformSets.clear()

func clean_textures():
	for t in textures:
		gpu.free_rid(t)
	gpu.free_rid(base_texture)
	
func clean_uniforms(from: int):
	for i in range(from,len(uniformSets)):
		var uni = uniformSets[i]
		gpu.free_rid(uni)
	uniformSets.resize(from)


	
########################################################
#					Channel mixer functions

func _update_buffer(ID: int, buf_data: PackedByteArray, at_position:int = 0):
	
	var buf_struct: BufferStruct = buffer_mapper[effect_order_mapper.find(ID)]

	gpu.buffer_update(buf_struct.buffer_id , 4*at_position, buf_data.size(), buf_data,RenderingDevice.BARRIER_MASK_COMPUTE)
	
#	print("UPDATED BUFFER, ID: ", ID, ", POS: ", effect_order_mapper.find(ID), " SHADER: ", SHADER_NAMES[buf_struct.shader_id])
#	print("BUFFER SIZE: ", buf_data.size())
	
func map_effect_buffer(ID: int,  shader_id: SHADER,  int_data: PackedInt32Array, float_data: PackedFloat32Array):
	var buf_data: PackedByteArray = int_data.to_byte_array() + float_data.to_byte_array()
	print("CREATOMG BUFFER WITH SHADER ID: ", SHADER_NAMES[shader_id], " WITH SIZE: ", buf_data.size())
	print("int data: ", int_data, "   float data: ", float_data)
	print("buf data: ", buf_data, " buf data size: ", buf_data.size())
	var buffer
	if buf_data.size() != 36:
		buffer = gpu.uniform_buffer_create(buf_data.size(),buf_data)
	else:
		buffer = gpu.uniform_buffer_create(buf_data.size() * 4)
		gpu.buffer_update(buffer,0,buf_data.size(), buf_data,RenderingDevice.BARRIER_MASK_COMPUTE )
	var buf_struct: BufferStruct = BufferStruct.new(ID,shader_id ,buffer)
	buffer_mapper.append(buf_struct)
	effect_order_mapper.push_back(ID)

func change_effect_order(ID: int, new_index: int):
	var current_index = effect_order_mapper.find(ID)
	
#	var current_index = 0
#
#	var effect_at_new_index: BufferStruct = buffer_mapper[new_index]
#	for index in len(buffer_mapper):
#		var effect := buffer_mapper[index]
#		if effect.ID == ID:
#			current_index = index
#			break

	print("CURRENT ORDER BEFORE: ")
	for index in len(effect_order_mapper):
		print("index:", index,": ", "order index: ", effect_order_mapper[index])
	print("BUFFER ORDER BEFORE: ")
	for index in len(buffer_mapper):
		print("index: ", index,": ID", buffer_mapper[index].ID," : ", SHADER_NAMES[buffer_mapper[index].shader_id])
	
	if current_index == new_index:
		print("CURRENT INDEX IS SAME AS NEW INDEX, RETURNING")
		return
	effect_order_mapper.remove_at(current_index)
	effect_order_mapper.insert(new_index,ID)
	var buf_struct = buffer_mapper[current_index]
	buffer_mapper.remove_at(current_index)
	buffer_mapper.insert(new_index,buf_struct)

#	var effect_to_change = buffer_mapper[current_index]
#	buffer_mapper[current_index] = buffer_mapper[new_index]
#	buffer_mapper[new_index] = effect_to_change
#
#	effect_order_mapper[ID] = new_index
#	effect_order_mapper[effect_at_new_index.ID] = current_index
	
	print("CHANGED ID: ",ID, " WITH INDEX: ", current_index," TO NEW INDEX: ", new_index )
	# since we changed the effect order, we have to rebuild the pipelines
	recreate_pipelines_and_uniforms()

var mask_buffer_mapper : Dictionary = {}
 

func create_mask_effect_buffer(_name: String, int_data: PackedInt32Array, float_data: PackedFloat32Array) -> int:
	if !mask_buffer_mapper.has(_name):
		mask_buffer_mapper[_name] = MaskBuffer.new()
	
	var mask_buf: MaskBuffer = mask_buffer_mapper[_name]
	var buf_data: PackedByteArray = int_data.to_byte_array() + float_data.to_byte_array()
	var buffer = gpu.storage_buffer_create(buf_data.size(),buf_data)
	
	return mask_buf.add_buffer(buffer)


func update_mask_name_in_mask_buffer_mapper(newName: String, oldName: String):
	if !mask_buffer_mapper.has(oldName):
		push_error("NO SUCH MASK: ", oldName)
	var buf = mask_buffer_mapper[oldName]
	mask_buffer_mapper.erase(oldName)
	mask_buffer_mapper[newName] = buf


func update_mask_buffer(_name: String, buf_index: int, buf_data: PackedByteArray, at_position:int = 0):
	if !mask_buffer_mapper.has(_name):
		push_error("NO SUCH MASK: ", _name,"! Cannot update buffer")
	
	var mask_buf: MaskBuffer = mask_buffer_mapper[_name]
	
	gpu.buffer_update(mask_buf.buffers[buf_index], 4*at_position, buf_data.size(), buf_data,RenderingDevice.BARRIER_MASK_COMPUTE)
	print("UPDATED MASK BUFFER")

func mask_buffer_next_offset(_name: String, buf_index: int) -> int:
	if !mask_buffer_mapper.has(_name):
		push_error("NO SUCH MASK: ", _name)
	
	var mask_buf: MaskBuffer = mask_buffer_mapper[_name]
	
	return mask_buf.get_next_offset(buf_index)

var custom_effect_pipelines: Array[RID] = []
var custom_effect_shaders: Array[RID] = []
var custom_effect_buffers: Array[RID] = []
var custom_effect_uniforms: Array[RID] = []

func clear_custom_effects():
	print("CLEARING CUSTOM EFFECTS")
	for rid in custom_effect_pipelines:
		gpu.free_rid(rid)
#	for rid in custom_effect_shaders:
#		gpu.free_rid(rid)
#	for rid in custom_effect_buffers:
#		gpu.free_rid(rid)
	for rid in custom_effect_uniforms:
		gpu.free_rid(rid)

	custom_effect_uniforms.resize(0)
	custom_effect_pipelines.resize(0)
#	custom_effect_buffers.resize(0)
#	custom_effect_shaders.resize(0)


func setup_custom_effects():
	clear_custom_effects()
	create_custom_effect_uniform()
	create_custom_effect_pipelines()


func get_custom_effects_num() -> int:
	return custom_effect_shaders.size()

func add_custom_effect_shader(index, rid:RID):
	print("ADDED CUSTOM SHADER")
	#TODO: THIS IS VERY BAD!!
#	clear_custom_effects()
	if custom_effect_shaders.size() != 0 and index < custom_effect_shaders.size():
		custom_effect_shaders.remove_at(index)

	if index == 0:
		custom_effect_shaders.insert(index, rid)
		print("shader did not exist, added it")
	else:
		print("shader did exist, recreating it")
		custom_effect_shaders.insert(index - 1, rid)
	print("CUSTOM SHADER SIZE: ", custom_effect_shaders.size())
	recreate_pipelines_and_uniforms()


func create_custom_effect_pipelines():
	for rid in custom_effect_shaders:
		print("CREATING CUSTOM EFFECT PIPELINE")
		var p_rid = gpu.compute_pipeline_create(rid)
		custom_effect_pipelines.push_back(p_rid)
		
func create_custom_effect_uniform():
	for index in len(custom_effect_shaders):
		print("CREATING CUSTOM EFFECT UNIFORM")
		var u0 = RDUniform.new()
		u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		u0.binding = 0
		u0.add_id(textures[current_texture].get_rd_texture_rid())
		
		current_texture = 1 - current_texture

		var u1 = RDUniform.new()
		u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		u1.binding = 1
		u1.add_id(textures[current_texture].get_rd_texture_rid())

		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		uniform.binding = 2
		uniform.add_id(custom_effect_buffers[index])

		var uniform_set_ = gpu.uniform_set_create([u0, u1, uniform], custom_effect_shaders[index], 0)

		custom_effect_uniforms.push_back(uniform_set_)

func apply_custom_effects():
	for index in len(custom_effect_pipelines):
		print("APPLYING CUSTOM EFFECT")
		var cmd = gpu.compute_list_begin()
		gpu.compute_list_bind_compute_pipeline(cmd, custom_effect_pipelines[index])
		gpu.compute_list_bind_uniform_set(cmd, custom_effect_uniforms[index], 0)
		gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)
		gpu.compute_list_end()


func update_custom_effect_buffer(index, data: PackedByteArray, update_pos:int):
	var buf_rid = custom_effect_buffers[index]
	print("UPDATED BUFFER WITH DATA: ", data)
	print("UPDATE POS: ", update_pos)
	print("UPDATE BUFFER SIZE: ", data.size())
	gpu.buffer_update(buf_rid, update_pos * 4, data.size(), data, RenderingDevice.BARRIER_MASK_ALL_BARRIERS)

func get_custom_buffer(index_):
	return gpu.buffer_get_data(custom_effect_buffers[index_])

func create_custom_effect_buffer(index, int_data: PackedInt32Array, float_data: PackedFloat32Array, bool_values: PackedInt32Array):
	if custom_effect_buffers.size() != 0 and index < custom_effect_buffers.size():
		gpu.free_rid(custom_effect_buffers[index])
		custom_effect_buffers.remove_at(index)
		
#	else:
#		print("ERROR CREATING CUSTOM EFFECT BUFER")
#
	var buf_data = int_data.to_byte_array() + float_data.to_byte_array() + bool_values.to_byte_array()
	print("CREATED CUSTOM EFFECT BUFFER WITH SIZE: ", buf_data.size(), ", AND DATA: ", buf_data)
	var buf_rid = gpu.storage_buffer_create(buf_data.size(), buf_data)
	
	if index == 0:
		custom_effect_buffers.insert(index, buf_rid)
#		print("buffer did not exist")
	else:
#		print("buffer existed, recreating it")
		custom_effect_buffers.insert(index - 1, buf_rid)
	


