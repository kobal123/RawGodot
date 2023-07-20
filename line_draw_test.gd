extends Control

var line2d = Line2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in range(1000):
#		for k in range(1000):
#			lines.push_back(Vector2(i,k))
#			lines.push_back(Vector2(i,k+1))
	loop_test()
#	add_child(line2d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	queue_redraw()
#	var s = Time.get_ticks_msec() 
#	line2d_draw()
#	var e = Time.get_ticks_msec()
#	print("time taken: " , e-s)
#	print("time to process frame: ", Performance.get_monitor(Performance.TIME_PROCESS))


func loop_test():
	var rand
	var s = Time.get_ticks_msec()
	for i in range(1000):
		for k in range(501):
			rand = k+i
			rand = k+i
			rand = k+i
	var e = Time.get_ticks_msec()
	print("LOOP TOOK: ", e-s, "ms ")

var poly = []
var multi = []
var single = []

#func _draw():
#	polyline_draw()
#	print("Drew polyline")
#	for i in range(3):
#		polyline_draw()
#		multiline_draw()
#		singleline_draw()
#
#	stats()
var lines = PackedVector2Array()

func sum(accum, number):
	return accum + number



func stats():
	for a in [poly, multi, single]:
		print("max: ", a.max())
		print("min: ", a.min())
		print("mean ", a.reduce(sum,0)/(len(a) if len(a) !=0 else 1))

func polyline_draw():
	var l = PackedVector2Array()
	var e = Time.get_ticks_msec()
	for i in len(lines)-1:
		l.push_back(lines[i])
		l.push_back(lines[i+1])
	draw_polyline(l, Color.RED)
	var s = Time.get_ticks_msec()
	print("polyline took: ", s-e)
	poly.push_back(s-e)

func line2d_draw():
	line2d.clear_points()
	for i in len(lines)-1:
		line2d.add_point(lines[i])
		line2d.add_point(lines[i+1])


func singleline_draw():
	var e = Time.get_ticks_msec()
	for i in len(lines)-1:
		draw_line(lines[i], lines[i+1], Color.RED)
	var s = Time.get_ticks_msec()
	print("single line took: ", s-e)
	single.push_back(s-e)

func multiline_draw():
	var l = PackedVector2Array()
	var e = Time.get_ticks_msec()
	for i in len(lines)-1:
		l.push_back(lines[i])
		l.push_back(lines[i+1])
	draw_multiline(lines, Color.RED)
	var s = Time.get_ticks_msec()
	print("multiline took: ", s-e)
	multi.push_back(s-e)


func _on_button_pressed():
	queue_redraw()
