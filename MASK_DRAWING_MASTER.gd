extends Node

var usage = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT\
	| RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT\
	| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

var current_mask: ImageTexture;
var editing:bool = false;

var texture_width: int
var texture_height: int


var MASK_IMAGE_FORMAT = Image.FORMAT_LA8

var brush_size: float = 400

var erasing: bool = false

func toggle_erasing():
	erasing = !erasing
	if current_mask_overlay != null:
		emit_signal("erasing_changed", erasing)
	brush.fill(Color(1,0,0,0))
	var size_ = float(brush.get_width() - 1) / 2.0
	circleBres(size_, size_, size_, brush)
	resize_mask_overlay_brush()

# base for creating a new mask
# size should be equal to the currently loaded image
# all drawing actions will be performed on this texture.
var mask_base: Image
var current_mask_overlay: Image


var current_mask_name: String

# 1:1 masks
var masks:Dictionary = {}

# smaller masks used for drawing.
var overlay_masks: Dictionary = {} 
var masks_name_ordered: Array[String] = []

signal create_mask_panel(name_: String)
signal mask_was_created(name:String)
signal editing_changed(value: bool)
signal mask_drawing
signal mask_changed
signal erasing_changed(value: bool)



signal mask_renamed(old_name: String, new_name: String)
func rename_mask(mask_name: String):
	pass #TODO


func get_mask_names() -> Array[String]:
	return masks_name_ordered


#blits image at positon
func paint(position: Vector2i):
	if !editing or mask_base == null:
		return
	mask_base.blit_rect_mask(brush, brush, Rect2i(0, 0, brush.get_width(), brush.get_height()), position - brush.get_size()/2)
#	current_mask_overlay.blit_rect_mask(brush, brush, Rect2i(0, 0, brush.get_width(), brush.get_height()), mask_position - brush.get_size()/2)
	was_painted = true
	emit_signal("mask_drawing")


func paint_overlay(position):
	if !editing or mask_base == null:
		return
#	print("OVERLAY PAINT")
#	mask_base.blit_rect_mask(brush, brush, Rect2i(0, 0, brush.get_width(), brush.get_height()), position - brush.get_size()/2)
	var s = Time.get_ticks_msec()
#	for pos in AppNodeConstants.get_mask_overlay().draw_positions:
#		var p = Vector2i(pos)
#		current_mask_overlay.blit_rect_mask(overlay_brush, overlay_brush, Rect2i(0, 0, overlay_brush.get_width(), overlay_brush.get_height()), p - overlay_brush.get_size()/4)
#
	
	current_mask_overlay.blit_rect_mask(overlay_brush, overlay_brush, Rect2i(0, 0, overlay_brush.get_width(), overlay_brush.get_height()), position - overlay_brush.get_size()/4)
	var e = Time.get_ticks_msec()
#	print("BLIT TOOK: ", e-s)
#	print("EVENT POS2 :", position)
	
#	if erasing:
#		get_current_mask_overlay().update(current_mask_overlay)

	get_current_mask_overlay().update(current_mask_overlay)
	was_painted = true
#	if erasing:
#		get_current_mask_overlay().update(current_mask_overlay)



#	get_current_mask_overlay().update(current_mask_overlay)
#	print(get_current_mask_overlay().get_size())
#	print(current_mask_overlay.get_size())
#	print("overlay brush size: ", overlay_brush.get_size())


var was_painted: bool = false

func update_mask():
	
	if current_mask == null or !was_painted:
		return

#	RenderingServer.get_rendering_device().texture_update(current_mask.get_rd_texture_rid(),0, mask_base.get_data())
	var s = Time.get_ticks_msec()
	current_mask.update(mask_base)
	var e = Time.get_ticks_msec()
	print("BIG MASK UPDATE TOOK: ", e-s, "MS")
	var ss = Time.get_ticks_msec()
	get_current_mask_overlay().update(current_mask_overlay)
	var ee = Time.get_ticks_msec()
	print("SMALL MASK UPDATE TOOK ", ee-ss,"MS")
	ComputePipeLineManager.apply_effects()
	was_painted = false

func is_mask_base_created():
	return !mask_base;

func get_texture_by_name(name_:String) -> Texture:
	if !masks.has(name_):
		print("ERROR, NO SUCH MASK: ", name_)
		return
	print("returning texture")
	return masks[name_]


func get_overlay_texture_by_name(mask_name):
	return overlay_masks[mask_name]


func set_brush_size(value):
	brush.resize(int(value), int(value), Image.INTERPOLATE_NEAREST)
	brush.fill(Color(1,0,0,0))
	var size_ = float(brush.get_width() - 1) / 2.0
	circleBres(size_, size_, size_, brush)
	resize_mask_overlay_brush()
	AppNodeConstants.get_mask()._on_resized()

func set_current_mask(mask_name:String) -> void:
	current_mask = masks[mask_name]
	mask_base = current_mask.get_image()
	current_mask_overlay = overlay_masks[mask_name].get_image()
	current_mask_name = mask_name
	emit_signal("mask_changed")

var created_masks:int = 0



func resize_mask_overlay_brush():
	var s = Time.get_ticks_msec()
	var radius = ceil(max(texture_width / brush.get_width(), texture_height / brush.get_width()))
	radius = floor(Vector2(1426.0, 945.0).x / radius)
#	overlay_brush.copy_from(brush)
	overlay_brush.resize(int(radius)*2,int(radius)*2, Image.INTERPOLATE_NEAREST)
	overlay_brush.fill(Color(1,0,0,0))
	var size_ = float(radius - 1) / 2
	circleBres(size_, size_, size_, overlay_brush)
	print("BRUSH SIZE: ", brush.get_size())
	print("OVERLAY BRUSH SIZE: ", overlay_brush.get_size())
	
	
	
	
# when the mask overlay is resized, we have to resize
# the associated overlay texture.
# it could be optimized to not update each mask!
func resize_mask_overlays(mask_overlay_size: Vector2):
	if overlay_masks.size() == 0:
		return
	
	print("RESIZING OVERLAY MASKS")

#	var mask: ImageTexture = overlay_masks[current_mask_name]
#	var mask_image = mask.get_image()
#	mask_image.resize(mask_overlay_size.x, mask_overlay_size.y)
#	mask_image.fill(Color(0.5, 0.0, 0.0,1.0))
##	mask.set_size_override(Vector2(mask_overlay_size))
#	mask.set_image(mask_image)
#
#	overlay_masks[current_mask_name] = mask 
#	current_mask_overlay = mask_image
	resize_mask_overlay_brush()

func get_current_mask_overlay() -> ImageTexture:
#	print("RETURNING CURRENT MASK OVERLAY: ", overlay_masks[current_mask_name])
	return overlay_masks[current_mask_name]


func create_mask(name_:String = ""):
	name_ = "MASK" + str(created_masks)

	if masks.has(name_):
		push_warning("MASK ALREADY EXISTS")
		return
	
	
	var mask = ImageTexture.create_from_image_with_usage(setup_mask_base(), usage)
	
	var mask_overlay_size = Vector2(1426, 945.0)
	var overlay_image = Image.create(mask_overlay_size.x, mask_overlay_size.y, false, MASK_IMAGE_FORMAT) 
	overlay_image.fill(Color(0.5, 0.0, 0.0,1.0))
	var overlay = ImageTexture.create_from_image(overlay_image)
	
	masks[name_] = mask
	overlay_masks[name_] = overlay
	masks_name_ordered.push_back(name_)
#	print("CREATED NEW MASK")
	emit_signal("create_mask_panel", name_)
	emit_signal("mask_was_created",name_)
	created_masks += 1

func switch_editable() -> void:
	editing = !editing;
	emit_signal("editing_changed", editing)



#var image_: Image
var texture_: ImageTexture
var brush: Image = Image.create(400, 400, false, MASK_IMAGE_FORMAT)
var overlay_brush: Image = Image.create(1,1,false, MASK_IMAGE_FORMAT)

#var img:Image = Image.load_from_file("res://result.png")

func set_texture_size(t_width:int, t_height:int):
	texture_width = t_width
	texture_height = t_height

# sets up mask texture
func setup_mask_base() -> Image:
	
	var mask_base_ = Image.create(texture_width,texture_height,false, MASK_IMAGE_FORMAT)
	mask_base_.fill(Color(0.5, 0.0, 0.0,1.0))
	print("CREATED MASK BASE TEXTURE")
	return mask_base_
	
func _ready():
	brush.fill(Color(1,0,0,0))
	var size_ = float(brush.get_width() - 1) / 2.0
	circleBres(size_, size_, size_, brush)
	
	
#
#
#	print(OS.get_static_memory_usage())
#	texture_ = ImageTexture.new()
#	mask_base = Image.create(6024,4024,false,Image.FORMAT_LA8)
#
#	#image_ = Image.create(6024,4024,false,Image.FORMAT_RGBA8)
##	image_ = Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
#	print(OS.get_static_memory_usage())
#
#	mask_base.fill(Color(0.5, 0.0, 0.0,1.0))


func get_current_mask() -> ImageTexture:
	return current_mask


#func _input(event):
#	return
#	if !editing:
#		return
#	if event is InputEventMouseMotion:
#		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
#
##			var s = Time.get_ticks_msec()
#			mask_base.blit_rect_mask(brush,brush,Rect2i(0,0,brush.get_width(),brush.get_height()),Vector2i(int(event.position.x * 3.1375), int(event.position.y * 3.72592)))
#			#image_.blit_rect(img,Rect2i(0,0,img.get_width(),img.get_height()),event.position )
#			current_mask.update(mask_base)
##			var e = Time.get_ticks_msec()
##			print(e-s)




func drawCircle(xc, yc , x, y, image):
#	var c = Color(1,0,0,0.1)
	var c
	if erasing:
		c = Color(0.5, 0.0, 0.0,1.0)
	else:
		c = Color(1,0,0,0.1)
	#img.set_pixel(xc+x, yc+y, c);
	#img.set_pixel(xc-x, yc+y, c);
	draw_line_(xc+x, xc-x, yc+y, c, image)
	#img.set_pixel(xc+x, yc-y, c);
	#img.set_pixel(xc-x, yc-y, c);
	draw_line_(xc+x, xc-x, yc-y, c, image)
	
	#img.set_pixel(xc+y, yc+x, c);
	#img.set_pixel(xc-y, yc+x, c);
	draw_line_(xc+y, xc-y, yc+x, c, image)
	
	#img.set_pixel(xc+y, yc-x, c);
	#img.set_pixel(xc-y, yc-x, c);
	draw_line_(xc+y, xc-y, yc-x, c, image)
	

func draw_line_(x0, x1, y, c, image):
	var x = x0
	var xx = x1
	while x != xx:
		image.set_pixel(x, y, c);
		x -= 1



# Function for circle-generation
# using Bresenham's algorithm
func circleBres(xc, yc, r, image):
	var x = 0
	var y = r;
	var d = 3 - 2 * r;
	drawCircle(xc, yc, x, y, image);
	while (y >= x):
#for each pixel we will
#draw all eight pixels

		x+= 1;

	#check for decision parameter
	#and correspondingly
	#update d, x, y
		if (d > 0):
			y-=1
			d = d + 4 * (x - y) + 10;

		else:
			d = d + 4 * x + 6;
		drawCircle(xc, yc, x, y, image);




#setup slider
#func _on_h_slider_value_changed(value):
#	img.resize(int(value),int(value))
#	var c = (value-1.0)/2.0
#	circleBres(c,c,c)

