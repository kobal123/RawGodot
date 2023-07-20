extends CanvasLayer

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_shader_param(param, value):
	print("SETTING SHADER PARAMS: ",param," WITH VALUE: ", value)
	var r = get_child(0)
	r.material.set_shader_parameter(param, value)


func set_rect_shader(_shader,_size,_position):
	var r = get_child(0)
	
	r.size = _size
	r.position = _position

	r.material.shader= _shader
