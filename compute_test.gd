extends Node
 
@export var texture: Texture2D
@export var texture2: Texture2D
 
func _ready():
	var img = texture.get_image()
	var img_pba = img.get_data()
	# We will be using our own RenderingDevice to handle the compute commands
	var rd = RenderingServer.get_rendering_device()
	print("ÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁ")
	# Create shader and pipeline
	var shader_file = load("res://test_comp_shader_.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	print(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE))
	var shader = rd.shader_create_from_spirv(shader_spirv)
	var pipeline = rd.compute_pipeline_create(shader)
	
	var pba = PackedFloat32Array()
	pba.resize(6024*4024)
	#print("size: ",  pba)
	#var buffer := rd.storage_buffer_create(6024*4024, pba.to_byte_array())
	
	Texture
	# Create uniform set using the storage buffer



	var usage = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT\
	| RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	RenderingServer
	var tex = ImageTexture.create_from_image_with_usage(img, usage)
	print(tex.get_rid())
	print(tex.get_rd_texture_rid())
	print(RenderingServer.texture_get_rd_rid(tex.get_rid()))
	var fmt = RDTextureFormat.new()
	fmt.width = img.get_width()
	fmt.height = img.get_height()
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	fmt.format = RenderingDevice.DATA_FORMAT_R8G8B8_UINT
	
	var buffer_uniform = RDUniform.new()
	buffer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	buffer_uniform.binding = 0
	buffer_uniform.add_id(tex.get_rd_texture_rid())
	%TextureRect.texture = tex

	#var v_tex = rd.texture_create(fmt, RDTextureView.new(), [img_pba])
	var samp_state = RDSamplerState.new()
	samp_state.unnormalized_uvw = true
	var samp = rd.sampler_create(samp_state)
	
#	var tex_uniform = RDUniform.new()
#	tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
#	tex_uniform.binding = 0
#	tex_uniform.add_id(samp)
	#tex_uniform.add_id(v_tex)
	var uniform_set = rd.uniform_set_create([buffer_uniform], shader, 0)
	
	
	var start = Time.get_ticks_usec()
	
	# Start compute list to start recording our compute commands
	var compute_list = rd.compute_list_begin()
	# Bind the pipeline, this tells the GPU what shader to use
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	# Binds the uniform set with the data we want to give our shader
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# Dispatch 1x1x1 (XxYxZ) work groups
	rd.compute_list_dispatch(compute_list, 6024/32, 4024/32, 1)
	#rd.compute_list_add_barrier(compute_list)
	# Tell the GPU we are done with this compute task
	rd.compute_list_end()
	# Force the GPU to start our commands
	rd.submit()
	# Force the CPU to wait for the GPU to finish with the recorded commands
	rd.sync()
 
	# Now we can grab our data from the storage buffer
	var end = Time.get_ticks_usec()
	print("time taken: ", end - start)

	#%TextureRect.texture = 
	
