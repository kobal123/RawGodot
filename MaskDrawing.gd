class_name CROP
extends Control

signal rect_size_changed(rect_: Rect2i)

enum CROP_ASPECT{
	CUSTOM,
	AS_SHOT,
	FOUR_BY_FIVE,
	FOUR_BY_THREE,
	SIXTEEN_BY_NINE,
	TWO_BY_THREE,
	ONE_BY_ONE,
}

var current_aspect: CROP_ASPECT = CROP_ASPECT.FOUR_BY_FIVE
var current_image_aspect

func set_aspect(aspect: CROP_ASPECT):
	current_aspect = aspect

var draw_positions: Array[Vector2] = []
var color = Color(1.0,1.0,0.0,1.0)

var crop_size
var crop_offset = Vector2(0.0, 0.0)


#these are the positions in image space
var crop_rect_top_left = Vector2i(0, 0)
var crop_rect_bottom_right = Vector2i(0, 0)

func _ready():
	crop_size = Vector2(-1,-1)
	print("crop size ", crop_size)

func add_pos(pos:Vector2):
	draw_positions.push_back(pos)
	queue_redraw()

var pos = Vector2(0.0, 0.0)

func get_crop_rect() -> Rect2i:
	return Rect2i(crop_rect_top_left, crop_rect_bottom_right - crop_rect_top_left)

var color_ = Color.ORANGE

func _draw():
#	return
	draw_rect(Rect2(pos , crop_size),Color(1.0,0.0,0.0,0.5),false, 5.0)
	
	draw_circle(pos,6, color_)
	draw_circle(Vector2(crop_size.x, 0) + pos, 6, color_)
	draw_circle(Vector2(0, crop_size.y) + pos, 6, color_)
	draw_circle(crop_size + pos, 6, color_)
	draw_circle(Vector2(crop_size.x/2, 0) + pos, 6, color_)
	draw_circle(Vector2(crop_size.x/2, crop_size.y) + pos, 6, color_)
	draw_circle(Vector2(crop_size.x/2, 0) + pos, 6, color_)
	draw_circle(Vector2(0, crop_size.y/2) + pos, 6, color_)
	draw_circle(Vector2(crop_size.x, crop_size.y/2) + pos, 6, color_)

	
	
##	print(get_rect())
#	return
#	if MaskDrawingMaster.erasing:
#		return
#
#	var img = AppNodeConstants.get_image_node()
#	var asp_ratio = float(img.texture.get_width())/float(img.texture.get_height())
#	var texture_width = img.scale.x * img.get_size().y * asp_ratio
#	var texture_height = img.scale.y* img.get_size().y
#	var padding_ = ((img.scale.x * img.get_size().x - texture_width) / 2 )
#	var radius = ceil(max(img.texture.get_width() / 200.0, img.texture.get_height() / 200.0))
#	radius = floor(size.x/radius)
#
#	print(img.get_size().x)
#	print(texture_width)
#	print(img.get_size().x - texture_width)
#	if padding_ < 0:
#		padding_ = 0
#
#	for index in len(draw_positions):
#		var pos = draw_positions[index]
#		var p = (pos -  Vector2(padding_, 0.0))
#		draw_circle(p, radius, color)

func set_color(color_):
	color = color_
	queue_redraw()

var last_size = null


func _on_resized():
#	print("RESIZING")
	if ComputePipeLineManager.base_texture != null:
		current_image_aspect = float(ComputePipeLineManager.base_texture.get_width()) / float(ComputePipeLineManager.base_texture.get_height())  

	if crop_size.x<0:
		crop_size = size


	if last_size != null:
		var dif =  (size - last_size)
		crop_size += Vector2(dif.x / (size.x / crop_size.x), dif.y / (size.y / crop_size.y))
		pos += Vector2(dif.x / (size.x / pos.x), dif.y / (size.y / pos.y))
	
	last_size = size
	
#	print("CROP SIZE: ", crop_size)
#	if len(draw_positions) == 0:
#		return
##	MaskDrawingMaster.update_mask()
#	draw_positions.clear()
	queue_redraw()

var is_mouse_at_crop_position: bool = false


var pressed = false

var drag_pos_start: Vector2 = Vector2(0.0, 0.0)

func _gui_input(event):
	var s = Time.get_ticks_usec()
	var top_left: bool = false
	var bottom_right: bool = false
	var bottom_left: bool = false
	var top_right: bool = false
	var drag: bool = false
	if event is InputEventMouseMotion or InputEventMouseButton:
		
		
		var right_top_diag = Vector2(abs(event.position.x - (crop_size.x + pos.x)), abs(event.position.y - pos.y))
		var right_down_diag = abs(event.position - crop_size - pos)
		var left_top_diag = Vector2(abs(event.position - pos))
		var left_down_diag = Vector2(abs(event.position.x - pos.x), abs(event.position.y - (crop_size.y + pos.y)))
		
		if left_top_diag.x < 40 and left_top_diag.y < 40:
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
			is_mouse_at_crop_position = true
			top_left = true
		elif right_down_diag.x < 40 and right_down_diag.y < 40:
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
			is_mouse_at_crop_position = true
			bottom_right = true

		elif left_down_diag.x < 20 and left_down_diag.y < 20:
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
			bottom_left = true
			is_mouse_at_crop_position = true
		elif right_top_diag.x < 20 and right_top_diag.y < 20:
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
			top_right = true
			is_mouse_at_crop_position = true

		elif Rect2(pos, crop_size).has_point(event.position):
			mouse_default_cursor_shape = Control.CURSOR_DRAG
			drag = true
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW
			is_mouse_at_crop_position = false


	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_mouse_at_crop_position:
				pressed = true
			if drag:
				drag_pos_start = event.position
		else:
			pressed = false
	elif event is InputEventMouseMotion and pressed:
		if top_left:
			var delta = event.position - pos
			var new_width = pos.x + crop_size.x - event.position.x
			var new_height = pos.y + crop_size.y - event.position.y
			var aspect_delta = get_delta_aspect(new_width, new_height)
			
#			pos = event.position
			pos.x = event.position.x
			pos.y = pos.y + crop_size.y - aspect_delta.y
			crop_size = aspect_delta
			
			var killswitch = 1
			if pos.y < 0:
				pos.y = 0
#				killswitch = 0.0
			if pos.x < 0:
				pos.x = 0
#				killswitch = 0.0
#			print("DELTA: ", delta, " DELTA ASPECT: ", aspect_delta)
#			crop_size -= (aspect_delta * killswitch)
		elif top_right:
			var new_width = event.position.x - pos.x
			var new_height = pos.y + crop_size.y - event.position.y 
			var aspect_delta = get_delta_aspect(new_width, new_height)
			pos.y = pos.y + crop_size.y - aspect_delta.y
			crop_size = aspect_delta
#			var delta = event.position - pos
#			pos.y = event.position.y
#			crop_size.x = delta.x#event.position.x - pos.x
#			crop_size.y -= delta.y
		elif bottom_left:
			var delta = event.position - pos
			pos.x = event.position.x
			crop_size.x -= delta.x
			crop_size.y = delta.y
			
		elif bottom_right:
#			if current_aspect == CROP_ASPECT.AS_SHOT:
#				var aspect_diff: Vector2 = Vector2(event.position.x, event.position.x / current_image_aspect)
#				crop_size -= (crop_size - aspect_diff + pos)
#			elif current_aspect == CROP_ASPECT.FOUR_BY_FIVE:
##				var aspect_diff: Vector2 = Vector2(event.position.x, event.position.x / 1.2)
#				var delta_aspect = get_delta_aspect(event.position)
#				crop_size -= (crop_size - delta_aspect + pos)
#
#			else:
##				crop_size -= (crop_size - event.position + pos)
			var delta_aspect := get_delta_aspect(event.position.x, event.position.y)
#			crop_size -= (crop_size - delta_aspect + pos)
			crop_size = delta_aspect - pos
		elif drag:
			var delta = event.position - drag_pos_start
			drag_pos_start = event.position
			if pos.x + delta.x + crop_size.x <= size.x and\
			pos.y + delta.y + crop_size.y <= size.y :
				pos += floor(delta)
			


		if crop_size.x + pos.x > size.x:
			var delta = crop_size.x + pos.x - size.x
			crop_size.x -= delta
		if crop_size.y + pos.y > size.y:
			var delta = crop_size.y + pos.y - size.y
			crop_size.y -= delta
			
		
		if crop_size.x < 100:
			crop_size.x = 100
		if crop_size.y < 100:
			crop_size.y = 100
		if pos.y < 0:
			pos.y = 0
		if pos.x < 0:
			pos.x = 0
		if abs(size.x - pos.x ) < 100:
			pos.x = size.x - 100
		if abs(size.y - pos.y ) < 100:
			pos.y = size.y - 100
# Calculate the scaling and offset factors

		var img = AppNodeConstants.get_image_node()


#		var scale_factor_width = crop_size.x / float(img.texture.get_width())
#		var scale_factor_height = crop_size.y / float(img.texture.get_height())
#		var offset_factor_left = pos.x / float(img.texture.get_width())
#		var offset_factor_top = pos.y / float(img.texture.get_height())
#		print("scale factor: ", scale_factor_height, " ", scale_factor_width)
#
#
#		# Map the crop rectangle coordinates to the image area space
#		var crop_left_image = int(offset_factor_left * img.texture.get_width())
#		var crop_top_image = int(offset_factor_top * img.texture.get_height())
#		var crop_right_image = int(crop_left_image + (scale_factor_width * img.texture.get_width()))
#		var crop_bottom_image = int(crop_top_image + (scale_factor_height * img.texture.get_height()))
#
#		print("CROP SIZE USING NEW FORMULA: ", crop_top_image," ",crop_left_image," ",crop_bottom_image," ",crop_right_image)

		crop_rect_top_left = Vector2i(int(((pos.x) * (img.texture.get_width() / size.x) )	) , int(pos.y * (img.texture.get_height() / size.y)) )
		crop_rect_bottom_right = Vector2i(int(((pos.x + crop_size.x) * (img.texture.get_width() / size.x) )	) , int((pos.y + crop_size.y) * (img.texture.get_height() / size.y)) )
		var e = Time.get_ticks_usec()
		print("time taken: ", e-s)
		print("RECT SIZE: ", get_crop_rect())
		
		queue_redraw()
		if !drag:
			emit_signal("rect_size_changed", get_crop_rect())

func get_delta_aspect(delta_x, delta_y) -> Vector2:
	if current_aspect == CROP_ASPECT.AS_SHOT:
		return Vector2(delta_x, delta_x / current_image_aspect)
#		crop_size -= (crop_size - aspect_diff + pos)
	elif current_aspect == CROP_ASPECT.FOUR_BY_FIVE:
		return Vector2(delta_x, delta_x / 1.25)
	elif current_aspect == CROP_ASPECT.FOUR_BY_THREE:
		return Vector2(delta_x, delta_x / 1.3333333)
	elif current_aspect == CROP_ASPECT.TWO_BY_THREE:
		return Vector2(delta_x, delta_x / 1.5)
	elif current_aspect == CROP_ASPECT.SIXTEEN_BY_NINE:
		return Vector2(delta_x, delta_x / 1.777777777)
	elif current_aspect == CROP_ASPECT.ONE_BY_ONE:
		return Vector2(delta_x, delta_x)
	else:
		return Vector2(delta_x, delta_y)
