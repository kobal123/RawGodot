extends Control

var albedo_tex: ImageTexture
var ping : ImageTexture
var pong : ImageTexture



var gpu: RenderingDevice
var shader: RID
var saturation_shader: RID

var compute_kernel: RID
var saturation_kernel: RID
var uniform_set: RID
var uniform_set2: RID


var buffer: RID
var buffer2: RID
var width = 6024
var height = 4024
var usage = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT\
	| RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT


#Contains the buffer IDs for the shaders used by the RenderingDevice
var buffers: Array[RID] = []


# These go hand in hand, their sizes should be equal
# the uniform set at index X goes to the pipeline at index X
var uniformSets: Array[RID] = []
var pipelines: Array[RID] = []

# Array of textures used for ping-pong rendering
var textures: Array[ImageTexture] = []

var shaders: Array[RID] = []
# The base current texture, will be used as a base
# for the first pass of each rendering
var base_texture: ImageTexture


var current_texture: int = 0

var times = []

func _ready():
#	var albedo_image: Image
#	gpu = RenderingServer.get_rendering_device()
#	albedo_image = Image.load_from_file("res://sony.ARW")
#
#	albedo_tex = ImageTexture.create_from_image_with_usage(albedo_image, usage)
#	ping = ImageTexture.create_from_image_with_usage(albedo_image, usage)
#	pong = ImageTexture.create_from_image_with_usage(albedo_image, usage)
#
#	var shader_spirv = load("res://test_comp_shader_.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#
#	var shader_spirv_saturation = load("res://fs_saturation.glsl").get_spirv()
#	saturation_shader = gpu.shader_create_from_spirv(shader_spirv_saturation)
#	#################
#	var input := PackedFloat32Array([0.2])
#	var input_bytes := input.to_byte_array()
#	buffer = gpu.storage_buffer_create(input_bytes.size(), input_bytes)
#	buffer2 = gpu.storage_buffer_create(input_bytes.size(), input_bytes)
#	#################
#
#	compute_kernel = gpu.compute_pipeline_create(shader)
#	saturation_kernel = gpu.compute_pipeline_create(saturation_shader)
#	create_uniform_set()
#	create_uniform_set2()
#	update_material()
	ComputePipeLineManager.setup()
	ComputePipeLineManager.apply_effects()
	_update_mat()
	
	



	
	
	
#func load_shaders():
#	# load shaders dynamically from resources?
#	var shader_spirv = load("res://test_comp_shader_.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)
#	shader_spirv = load("res://fs_saturation.glsl").get_spirv()
#	shader = gpu.shader_create_from_spirv(shader_spirv)
#	shaders.push_back(shader)

	
	


func apply_effects():
	pass
	
func create_pipeline():
	#load shader
	#create shader
	#save shader rid
	#create pipeline
	#save pipeline rid
	pass


func create_uniform_set():
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 1
	u0.add_id(ping.get_rd_texture_rid())

	var u1 = RDUniform.new()
	u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u1.binding = 0
	u1.add_id(albedo_tex.get_rd_texture_rid())

# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 2 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)


	uniform_set = gpu.uniform_set_create([u0,u1,uniform], shader, 0)

func create_uniform_set2():
	var u0 = RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u0.binding = 0
	u0.add_id(ping.get_rd_texture_rid())

	var u1 = RDUniform.new()
	u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u1.binding = 0
	u1.add_id(ping.get_rd_texture_rid())

# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 1 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer2)
	uniform_set2 = gpu.uniform_set_create([u0,uniform], saturation_shader, 0)

func update_material():
	%TextureRect.texture = albedo_tex


func _update_mat():
	%TextureRect.texture = ComputePipeLineManager.get_current_texture()


func dispatch_kernel():
	var cmd = gpu.compute_list_begin()
	gpu.compute_list_bind_compute_pipeline(cmd, compute_kernel)
	gpu.compute_list_bind_uniform_set(cmd, uniform_set, 0)
	var size = Vector2i(6024,4024)
	var group_cnt = (size + Vector2i(31, 31)) / 32
	#print("group count: ", group_cnt)
	gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)
	gpu.compute_list_end()

func dispatch_kernel2():
	var cmd = gpu.compute_list_begin()
	gpu.compute_list_bind_compute_pipeline(cmd, saturation_kernel)
	gpu.compute_list_bind_uniform_set(cmd, uniform_set2, 0)
	var size = Vector2i(6024,4024)
	var group_cnt = (size + Vector2i(31, 31)) / 32
	#print("group count: ", group_cnt)
	gpu.compute_list_dispatch(cmd, group_cnt.x, group_cnt.y, 1)
	gpu.compute_list_end()

func _on_h_slider_value_changed(value):
	if len(times) == 1001:
		print("TIMES len is 1000")
		times.sort()
		var sum = 0
		for num in times:
			sum += num
		print("avg: ", sum / 1000 )
		print("median: ", times[501])
		return
#	var input := PackedFloat32Array([value])
#	var input_bytes := input.to_byte_array()
#	gpu.buffer_update(buffer,0,input_bytes.size(),input_bytes,RenderingDevice.BARRIER_MASK_COMPUTE)
#	var s = Time.get_ticks_usec()
	var s = Time.get_ticks_usec()
#
#	dispatch_kernel()
#	dispatch_kernel2()
#	var e = Time.get_ticks_usec()
#	print("time taken: ", e-s, "usec")
	ComputePipeLineManager.update_buffer(0,value)
	ComputePipeLineManager.apply_effects()
	var e = Time.get_ticks_usec()
	print("time taken: ", e-s, "usec")
	times.push_back(e-s)
	
func _on_h_slider_2_value_changed(value):
	if len(times) == 1001:
		print("TIMES len is 1000")
		times.sort()
		var sum = 0
		for num in times:
			sum += num
		print("avg: ", sum / 1000 )
		print("median: ", times[501])
		return
#	var input := PackedFloat32Array([value])
#	var input_bytes := input.to_byte_array()
#	gpu.buffer_update(buffer2,0,input_bytes.size(),input_bytes,RenderingDevice.BARRIER_MASK_COMPUTE)
	var s = Time.get_ticks_usec()
#
#	dispatch_kernel()
#	dispatch_kernel2()
	ComputePipeLineManager.update_buffer(1,value)
	ComputePipeLineManager.apply_effects()
	var e = Time.get_ticks_usec()
	print("time taken: ", e-s, "usec")
	times.push_back(e-s)
	



func _on_h_slider_3_value_changed(value):
	if len(times) == 1001:
		print("TIMES len is 1000")
		times.sort()
		var sum = 0
		for num in times:
			sum += num
		print("avg: ", sum / 1000 )
		print("median: ", times[501])
		return
#	var input := PackedFloat32Array([value])
#	var input_bytes := input.to_byte_array()
#	gpu.buffer_update(buffer2,0,input_bytes.size(),input_bytes,RenderingDevice.BARRIER_MASK_COMPUTE)
	var s = Time.get_ticks_usec()
#
#	dispatch_kernel()
#	dispatch_kernel2()
	ComputePipeLineManager.update_buffer(2,value)
	ComputePipeLineManager.apply_effects()
	var e = Time.get_ticks_usec()
	print("time taken: ", e-s, "usec")
	times.push_back(e-s)
