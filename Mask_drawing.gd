extends TextureRect



var cross = load("res://cross2.png").get_image()
var erase = load("res://cross.png").get_image()
var circle: Image = load("res://circle.png").get_image()

var eraser_circle: Image = load("res://circle.png").get_image()

var mouse_texture_add_paint: ImageTexture
var mouse_texture_remove_paint: ImageTexture



var texture_width
var texture_height
var padding_
var parent_size
var asp_ratio
var img: Control


var offset_x
var offset_y
var tex_width
var tex_height

func _ready():
	img = get_parent()
	cross.resize(32,32)
	circle.resize(128,128)
	circle.blit_rect(cross, Rect2i(0,0,cross.get_width(), cross.get_height()), circle.get_size()/2 - cross.get_size()/2)
	mouse_texture_add_paint = ImageTexture.create_from_image(circle)

	erase.resize(32,32)
	eraser_circle.resize(128,128)
	eraser_circle.blit_rect(erase, Rect2i(0,0,erase.get_width(), erase.get_height()), eraser_circle.get_size()/2 - erase.get_size()/2)
	mouse_texture_remove_paint = ImageTexture.create_from_image(eraser_circle)
	
	MaskDrawingMaster.connect("erasing_changed", Callable(self,"toggle_custom_mouse_texture"))


func _on_resized():
	var img = AppNodeConstants.get_image_node()
	if img.texture == null:
		return
	asp_ratio = float(img.texture.get_width())/float(img.texture.get_height())
	texture_width = scale.x * get_size().y * asp_ratio
	texture_height = scale.y * get_size().y
	padding_ = abs(((scale.x * get_size().x - texture_width) / 2 ))
	############################
	
	tex_width = img.texture.get_width() * size.y / img.texture.get_height();
	tex_height = size.y;

	if tex_width > size.x:
		tex_width = size.x;
		tex_height = img.texture.get_height() * size.x / img.texture.get_width();



	offset_x = (size.x - tex_width) / 2;
	offset_y = (size.y - tex_height) / 2;
	
	
	
	############################
	

	if img.texture == null:
		return

	var radius = ceil(max(img.texture.get_width() / MaskDrawingMaster.brush.get_width(), img.texture.get_height() / MaskDrawingMaster.brush.get_width()))
	var new_brush_size = floor(texture_width/radius)

	var addition_copy = Image.new()
	addition_copy.copy_from(circle)
	addition_copy.resize(new_brush_size, new_brush_size, 4)
	mouse_texture_add_paint.set_image(addition_copy)
	
	
	var erase_copy = Image.new()
	erase_copy.copy_from(eraser_circle)
	erase_copy.resize(new_brush_size, new_brush_size, 4)
	mouse_texture_remove_paint.set_image(erase_copy)
	_on_mouse_entered()
	
	##############






func _input(event):


	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT and MaskDrawingMaster.editing:
			event = make_input_local(event)
#			var img = AppNodeConstants.get_image_node()
#			var asp_ratio = float(img.texture.get_width())/float(img.texture.get_height())
#
#			var texture_width = scale.x * get_size().y * asp_ratio
#			var texture_height = scale.y*get_size().y
#			var padding_ = abs(((scale.x * get_size().x - texture_width) / 2 ))


			MaskDrawingMaster.paint(Vector2i(int(((event.position.x - offset_x) * (img.texture.get_width() / tex_width) ) - offset_x / (img.texture.get_width() / tex_width)) , int(event.position.y * (img.texture.get_height() / tex_height)) ))
			var overlay_pos = event.position - Vector2(padding_, 0.0)

#			print((event.position.x- padding_) * asp_ratio )
#	
#			var pos = Vector2i(int((event.position.x - padding_)) - (padding_ * asp_ratio) , int(event.position.y))
			
#			pos.x / 2.233333333, pos.y / 2.6370370
#			draw_positions.push_back(Vector2(event.position.x, event.position.y))
			
			
#			AppNodeConstants.get_mask_overlay().add_pos(event.position - Vector2(padding_,0.0))
#			AppNodeConstants.get_mask_drawing_overlay().add_pos(event.position)
#			MaskDrawingMaster.paint_overlay(Vector2i(int((event.position.x - padding_) * (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) ) - padding_ / (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) , int(event.position.y * (MaskDrawingMaster.get_current_mask_overlay().get_height() / texture_height))))
			MaskDrawingMaster.paint_overlay(Vector2i(int(event.position.x - offset_x) * (MaskDrawingMaster.get_current_mask_overlay().get_width() / tex_width), int((event.position.y - offset_y) * (MaskDrawingMaster.get_current_mask_overlay().get_height() / tex_height))))
			


#			var overlay_position = Vector2i(Vector2(((event.position.x - padding_) * (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) ) - padding_ / (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) , (event.position.y * (MaskDrawingMaster.get_current_mask_overlay().get_height() / texture_height))) / Vector2(MaskDrawingMaster.get_current_mask_overlay().get_size() / Vector2(texture_width, texture_height)))
#			MaskDrawingMaster.paint_overlay(overlay_position)
#			print("XXXXXXXXXXXXXXXXXXXXXXX")
#			print(overlay_position)
#			print(Vector2(((event.position.x - padding_) * (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) ) - padding_ / (MaskDrawingMaster.get_current_mask_overlay().get_width() / texture_width) , (event.position.y * (MaskDrawingMaster.get_current_mask_overlay().get_height() / texture_height))))
#			print(Vector2(MaskDrawingMaster.get_current_mask_overlay().get_size() / Vector2(texture_width, texture_height)))
#			print("XXXXXXXXXXXXXXXXXXXXXXX")

#			print(MaskDrawingMaster.get_current_mask_overlay().get_size())

#			AppNodeConstants.get_mask_overlay().add_event(event)
#			AppNodeConstants.get_mask_overlay().add_size(img.size)
			
			
			#image_.blit_rect_mask(img,img,Rect2i(0,0,img.get_width(),img.get_height()),Vector2i(int(event.position.x * 3.1375), int(event.position.y * 3.72592)))
			#image_.blit_rect(img,Rect2i(0,0,img.get_width(),img.get_height()),event.position )
			#texture.update(image_)
			var e = Time.get_ticks_msec()
#			print("PAINTING TOOK", e-s)
#			texture = MaskDrawingMaster.get_current_mask()


func toggle_custom_mouse_texture(erasing):
	print("TOGGLE CUSTOM MOUSE ", erasing)
	if erasing:
		Input.set_custom_mouse_cursor(mouse_texture_remove_paint, Input.CURSOR_ARROW, Vector2(mouse_texture_remove_paint.get_size()/2))
	else:
		Input.set_custom_mouse_cursor(mouse_texture_add_paint, Input.CURSOR_ARROW, Vector2(mouse_texture_add_paint.get_size()/2))



func _on_mouse_entered():
	#print("MOUSE ENTERED!!")
	if MaskDrawingMaster.editing:
		print("EDITING")
		print("set custom mouse cursor")
		if MaskDrawingMaster.erasing:
			Input.set_custom_mouse_cursor(mouse_texture_remove_paint, Input.CURSOR_ARROW, Vector2(mouse_texture_remove_paint.get_size()/2))
		else:
			Input.set_custom_mouse_cursor(mouse_texture_add_paint, Input.CURSOR_ARROW, Vector2(mouse_texture_add_paint.get_size()/2))
	

func _on_mouse_exited():
	#print("MOUSE EXITED!")
	MaskDrawingMaster.update_mask()
#	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2(mouse_texture_add_paint.get_size()/2))
