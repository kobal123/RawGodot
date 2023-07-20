extends TextureRect


var data: PackedInt32Array = [3512,1231,35153,353,0,3512,35121,12987,3213,21115,3321,456]

var range_min: float = 0.0
var range_max: float = 0
var target_min: float = 0.0
var target_max: float = 120.0


var max_val: float = -1

var line_width = 1

var rng = RandomNumberGenerator.new()
#
#func _process(delta):
#	texture = ComputePipeLineManager.HISTOGRAM_TEXTURE

#func _ready():
#	texture = ComputePipeLineManager.HISTOGRAM_TEXTURE
#	rng.randomize()
#	data.clear()
#	for i in range(1024):
#		var num = int(rng.randi_range(0,2000000))
#		data.push_back(num)
#		if num > range_max:
#			range_max = num


func asd(val):
	pass
	var a = ((val - range_min) / (range_max - range_min)) * 120.0

#func s():
#	data.clear()
#	for i in range(1024):
#		var num = int(rng.randi_range(0,2000000))
#		data.push_back(num)
#		if num > range_max:
#			range_max = num

func logWithBase(value, base):
	return log(value) / log(base)

func scale_(m: int) -> float:
	return 120 - (80 * m) / max_val
	
#	var log_scale = log(max_val)
#	var height_scale = 120.0 / log_scale
#	var scaled_height = log(m)
#	var height = clamp(scaled_height * height_scale, 0, 120)  # Limit the height of the bar to 120 pixels
#
#	return height

#	if m > 0:
##		print("SIZE: ", logWithBase(m, 10))
#		return logWithBase(m, 2) * 8
#
##	print("SIZE: ", 0.0)
#	return 120.0
#	return ((m + range_min) / (range_max - range_min)) * 120.0

	


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
	
	
func _draw():
#	return
	
	
	var s = Time.get_ticks_msec()
	var vecs := convert_data_to_vectors(data)
	if vecs == []:
		return

	draw_multiline(vecs[0],Color(1, 0, 0, 0.4), 1) # RED
	draw_multiline(vecs[1],Color(0, 1, 0, 0.4), 1) # GREEN
	draw_multiline(vecs[2],Color(0, 0, 1, 0.4), 1) # BLUE
	
	#draw_multiline(vecs[3],Color(1, 1, 1, 0.2), 1) # LUMA
	
	
	var e = Time.get_ticks_msec()
#	print("DRAW TOOK ", e-s,"ms ")

func convert_data_to_vectors(data: PackedInt32Array) -> Array[PackedVector2Array]:
	#				red/green/blue
	if data.size() < 2:
		return []
	var arr: Array[PackedVector2Array] = []
	var red := PackedVector2Array()
	var green := PackedVector2Array()
	var blue := PackedVector2Array()
	var luma := PackedVector2Array()


	var x_index_ = 0
	var pos = global_position

	var red_height
	var green_height
	var blue_height
	var luma_height
#
#	for index in range(0, data.size(), 4):
#		red_height = scale_(data[index])
#		green_height = scale_(data[index + 1])
#		blue_height = scale_(data[index + 2])
#		red.push_back(Vector2(x_index_, 120))
#		red.push_back(Vector2(x_index_, red_height if red_height >= 0.0 else 0.0  ))
#		green.push_back(Vector2(x_index_,120))
#		green.push_back(Vector2(x_index_, green_height if green_height >= 0.0 else 0.0  ))
#		blue.push_back(Vector2(x_index_, 120))
#		blue.push_back(Vector2(x_index_, blue_height if blue_height >= 0.0 else 0.0  ))
#		x_index_ += line_width
#
	for index in range(0, 512):
		red_height = scale_(data[index])
		red.push_back(Vector2(x_index_, 120))
		red.push_back(Vector2(x_index_, red_height if red_height >= 0.0 else 0.0  ))

		x_index_ += line_width

	x_index_ = 0
	for index in range(512, 1024):

		green_height = scale_(data[index])

		green.push_back(Vector2(x_index_,120))
		green.push_back(Vector2(x_index_, green_height if green_height >= 0.0 else 0.0  ))
		x_index_ += line_width


	x_index_ = 0
	for index in range(1024, 1536):
		blue_height = scale_(data[index])
		blue.push_back(Vector2(x_index_, 120))
		blue.push_back(Vector2(x_index_, blue_height if blue_height >= 0.0 else 0.0  ))
		x_index_ += line_width
		
	x_index_ = 0
	for index in range(1536, 2048):
		luma_height = scale_(data[index])
		luma.push_back(Vector2(x_index_, 120))
		luma.push_back(Vector2(x_index_, luma_height if luma_height >= 0.0 else 0.0  ))
		x_index_ += line_width
	
	arr.push_back(red)
	arr.push_back(green)
	arr.push_back(blue)
	arr.push_back(luma)
#	print("HISTOGRAM DRAW FINISHED, WIDTH: ",  x_index_)
	return arr



func set_data(data_: PackedInt32Array):
	
	var duplicated_arr := data_.duplicate()
	duplicated_arr.sort()
	
	max_val = duplicated_arr[1900];
#	max_val = duplicated_arr[2047]
	self.data = data_
	range_max = max_val
	range_min = duplicated_arr[0]

	
#	for d in len(data):
#		print(d," : ", data[d])
#	print("max VAL : ", max_val)
	queue_redraw()

