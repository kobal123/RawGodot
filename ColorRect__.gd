extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var t = get_node("/root/Control/TRect")
	material.set_shader_parameter("contrast",2.0)
	material.set_shader_parameter("text",t.texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_rect_texture_changed():
	var t = get_node("/root/Control/TRect")
	material.set_shader_parameter("text",t.texture)
