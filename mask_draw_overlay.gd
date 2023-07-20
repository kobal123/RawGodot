extends TextureRect


var draw_positions: Array[Vector2] = []

var events: Array = []

var old_size: Vector2
var size_scale: Vector2


var sizes: Array = []


var s_pos = Vector2(753.138, 500)


var color = Color(1.0,0.0,0.0,1.0)


#
#
#func add_pos(pos:Vector2):
##	var p = Vector2(pos.x / 2.233333333, pos.y / 2.6370370)
#	draw_positions.push_back(pos)
##	print(pos)
#	queue_redraw()
#
#func add_event(event):
##	var p = Vector2(pos.x / 2.233333333, pos.y / 2.6370370)
#	events.push_back(event)
#	queue_redraw()
#
#
#func add_size(s):
#	sizes.push_back(s)
#
##
##func _process(delta):
###	print("áááá")
##	print("CURRENT TEXTURE: ", texture)
##
#

#func _draw():
##	var rect = get_rect()
##	draw_line(position.x, position)
##	var pos: PackedVector2Array = [Vector2(position.x, position.x + size.x)]
#	draw_rect(get_rect(),Color(1.0,0.0,0.0,0.5),false, 2.0)
#	draw_rect(Rect2(0.0,0.0, 100.0, 100.0),Color.RED,false, 2.0)
#
##	draw_polyline()


func set_mask_overlay(_d = null):
#	print("SET MASK TEXTURE OVERLAY ")
	texture = MaskDrawingMaster.get_current_mask_overlay()
#
#
#func _draw():
#	if MaskDrawingMaster.erasing:
#		return
#
#	var img = AppNodeConstants.get_image_node()
#	var asp_ratio = float(img.texture.get_width())/float(img.texture.get_height())
##	var s = Time.get_ticks_usec()
#
#	var texture_width = img.scale.x * img.get_size().y * asp_ratio
#	var texture_height = img.scale.y* img.get_size().y
#	var padding_ = abs(((img.scale.x * img.get_size().x - texture_width) / 2 ))
#	var radius = ceil(max(img.texture.get_width() / 200.0, img.texture.get_height() / 200.0))
#	radius = floor(size.x/radius)
##	print("####################################")
##	draw_arc(get_local_mouse_position(), floor(size.x/radius), 0, TAU, 100, Color.WHITE)
#
#	for index in len(draw_positions):
##		print(pos)
##		draw_circle(Vector2(0.0,0.0,), 50, Color(0.0,0.0,0.0, 1.0))
#		var pos = draw_positions[index]
##		print("DRAWING CIRCLE")
#
##		var p = (pos - Vector2(padding_,0.0)) + (s - size)/(pos - Vector2(padding_,0.0))
#		var p = (pos -  Vector2(padding_, 0.0))
#
#
#
#		draw_circle(p, radius, color)
##		draw_circle(p, radius, Color(0.0,0.0,1.0,0.1))
#
##	draw_circle(Vector2(0,0), 1000, Color(0.0,0.0,1.0,0.1))
##	draw_arc(Vector2(0,0),1000,0, TAU, 64, Color(1.0,0.0,0.0,0.1), 20)

func _on_my_image_node_resized():
	pass


#	return
##	size = AppNodeConstants.get_image_node().size
##	position = AppNodeConstants.get_image_node().global_position
##	queue_redraw()

func set_color(color_):
	material.set_shader_parameter("color", color_)
#	queue_redraw()




#
#var cross = load("res://cross2.png").get_image()
#var neg  = load("res://cross.png").get_image()
#var circle: Image = load("res://circle.png").get_image()
#
#var mouse_texture: ImageTexture

func _process(delta):
	queue_redraw()

func _ready():
	MaskDrawingMaster.connect("mask_changed", Callable(self,"set_mask_overlay"))
	MaskDrawingMaster.connect("erasing_changed", Callable(self,"set_mask_overlay"))
#	cross.resize(32,32)
#	circle.resize(128,128)
#	circle.blit_rect(cross, Rect2i(0,0,cross.get_width(), cross.get_height()), circle.get_size()/2 - cross.get_size()/2)
#
#	mouse_texture = ImageTexture.create_from_image(circle)


var was_resized: bool = false

func _on_resized():
#	MaskDrawingMaster.resize_mask_overlays(size)
	was_resized = true
#
#
##	return
##	var img = AppNodeConstants.get_image_node()
##	var radius = ceil(max(img.texture.get_width() / 200.0, img.texture.get_height() / 200.0))
##
##	radius /= 2
##	print(2-floor(size.x/radius), "    ", floor(size.x/radius))
##	var copy = Image.new()
##	copy.copy_from(circle)
##	copy.resize(floor(size.x/radius),floor(size.x/radius),4)
##	mouse_texture.set_image(copy)
#
#
##	radius /= 2
##	circle.resize(floor(size.x/radius),floor(size.x/radius),4)
##	mouse_texture.set_image(circle)
#
#	if len(draw_positions) == 0:
#		return
#	MaskDrawingMaster.update_mask()
#	draw_positions.clear()
#	queue_redraw()




#
#func change_cursor(editing: bool):
#	if editing:
#		Input.
#	else:
#		pass
#



#func _on_mouse_entered():
#
#	if MaskDrawingMaster.editing:
#		print("set custom mouse cursor")
##		var img = Image.load_from_file("res://collapse_arrow.png")
#
#		Input.set_custom_mouse_cursor(mouse_texture, Input.CURSOR_ARROW, Vector2(mouse_texture.get_size()/2))


#func _on_mouse_exited():
#	print("DISABLED CUSTOM MOUSE")
##	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


func _on_mouse_entered():

#	print("MOUSE ENTERED!")
	if was_resized:
		was_resized = false
		MaskDrawingMaster.resize_mask_overlays(size)
		MaskDrawingMaster.update_mask()

