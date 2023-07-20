
extends TextureRect

var image_: Image
var texture_: ImageTexture
var img = Image.create(128,128,false,Image.FORMAT_LA8)
#var img:Image = Image.load_from_file("res://result.png")


var asdasd

var t_width
var t_height

var mask_positions = []

signal texture_changed

func _ready():
	print(OS.get_static_memory_usage())
	texture_ = ImageTexture.new()
	image_ = Image.create(6024,4024,false,Image.FORMAT_LA8)

	#image_ = Image.create(6024,4024,false,Image.FORMAT_RGBA8)
#	image_ = Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	print(OS.get_static_memory_usage())
	img.fill(Color(1,0,0,0))
	#image_.fill(Color(0.5, 0.0, 0.0))
	circleBres(127.0/2.0,127.0/2.0,127.0/2.0)
	image_.fill(Color(0.5, 0.0, 0.0,1.0))
	#img.resize(256,256)
	texture = ImageTexture.create_from_image(image_)
	print(texture.get_width())
	print(texture.get_height())


func _input(event):

	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			
			var s = Time.get_ticks_msec()
			image_.blit_rect_mask(img,img,Rect2i(0,0,img.get_width(),img.get_height()),Vector2i(int(event.position.x * 3.1375), int(event.position.y * 3.72592)))
			#image_.blit_rect(img,Rect2i(0,0,img.get_width(),img.get_height()),event.position )
			texture.update(image_)
			var e = Time.get_ticks_msec()
			print(e-s)




func drawCircle(xc, yc , x, y):
	var c = Color(1,0,0,0.1)
	#img.set_pixel(xc+x, yc+y, c);
	#img.set_pixel(xc-x, yc+y, c);
	draw_line_(xc+x,xc-x,yc+y,c)
	#img.set_pixel(xc+x, yc-y, c);
	#img.set_pixel(xc-x, yc-y, c);
	draw_line_(xc+x,xc-x,yc-y,c)
	
	#img.set_pixel(xc+y, yc+x, c);
	#img.set_pixel(xc-y, yc+x, c);
	draw_line_(xc+y,xc-y,yc+x,c)
	
	#img.set_pixel(xc+y, yc-x, c);
	#img.set_pixel(xc-y, yc-x, c);
	draw_line_(xc+y,xc-y,yc-x,c)
	

func draw_line_(x0,x1,y,c):
	var x = x0
	var xx = x1
	while x != xx:
		img.set_pixel(x, y, c);
		x -= 1



# Function for circle-generation
# using Bresenham's algorithm
func circleBres(xc, yc, r):
	var x = 0
	var y = r;
	var d = 3 - 2 * r;
	drawCircle(xc, yc, x, y);
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
		drawCircle(xc, yc, x, y);




func _on_h_slider_value_changed(value):
	img.resize(int(value),int(value))
	var c = (value-1.0)/2.0
	circleBres(c,c,c)

func _on_button_pressed():

	emit_signal("texture_changed")
