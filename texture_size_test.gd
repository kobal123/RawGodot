extends TextureRect


var mask_drawing_enabled: bool;

# Called when the node enters the scene tree for the first time.
func _ready():
	var a = RefCounted.new()
	
	if a:
		print("a is truthy")
	else:
		print("a is falsy")
	
	#self.material.set_shader_parameter("text",texture)
	var asp_ratio = 6024.0/4024.0
	var texture_width = get_size().y * asp_ratio
	var texture_height = get_size().y
	var padding_ = (get_size().x - texture_width) / 2
	print("my size is: ", get_size())
	print(texture_height," ", texture_width," left padding: ",padding_)
	%TRect.size = Vector2(texture_width,texture_height)
	%TRect.position = Vector2(padding_,0)
	texture_filter

	get_node("/root/Control/CanvasLayer/ColorRect").set_size(Vector2(texture_width,texture_height))
	get_node("/root/Control/CanvasLayer/ColorRect").set_position(Vector2(padding_,0))
# Called every frame. 'delta' is the elapsed time since the previous frame.





func _on_resized():
	print(scale * texture.get_size())
