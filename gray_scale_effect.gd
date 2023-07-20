extends VBoxContainer

const  rwgt = 0.3086;
const  gwgt = 0.6094;
const  bwgt = 0.0820;

enum CHANNEL {
	RED,
	GREEN,
	BLUE
}

var reds
var redsb

var greens
var greensb

var blues
var bluesb
# Called when the node enters the scene tree for the first time.
func _ready():
	reds = %RedSlider
	redsb = %RedSpinbox
	var redCallable = Callable(self, "set_values")
	var greenCallable = Callable(self, "set_values")
	var blueCallable = Callable(self, "set_values")
	redCallable = redCallable.bind(CHANNEL.RED)
	greenCallable = greenCallable.bind(CHANNEL.GREEN)
	blueCallable = blueCallable.bind(CHANNEL.BLUE)
	
#	reds.connect("value_changed",Callable(redsb, "set_value"))
#	redsb.connect("value_changed",Callable(reds, "set_value"))
	reds.connect("value_changed",redCallable)
	
#	redsb.connect("value_changed",Callable(self, "val"))
#	reds.connect("value_changed",Callable(self, "val"))
	greens = %GreenSlider
	greensb = %GreenSpinbox
#	greens.connect("value_changed",Callable(greensb, "set_value"))
#	greensb.connect("value_changed",Callable(greens, "set_value"))
	greens.connect("value_changed",greenCallable)
	
	blues = %BlueSlider
	bluesb = %BlueSpinbox

#	blues.connect("value_changed",Callable(bluesb, "set_value"))
#	bluesb.connect("value_changed",Callable(blues, "set_value"))
	blues.connect("value_changed",blueCallable)



var red_val = 61
var green_val = 31
var blue_val = 8

var delta1 = 0
var delta2 = 0


func set_values(_value, channel: CHANNEL):
	var delta = 0
#	print("caluclating values")
	if channel == CHANNEL.RED:
		var true_val = reds.value if reds.value == _value else redsb.value
		delta = true_val - red_val
		reds.set_block_signals(true)
		redsb.set_block_signals(true)
		reds.value = _value
		redsb.value = _value
#		print("RED: ", reds.value,", ", redsb.value)
		reds.set_block_signals(false)
		redsb.set_block_signals(false)

		
		delta1 = -blues.value / (greens.value + blues.value) * delta
		delta2 = -greens.value / (greens.value + blues.value) * delta  
		
		blues.set_block_signals(true)
		bluesb.set_block_signals(true)
		blues.value += delta1
		bluesb.value += delta1
		blues.set_block_signals(false)
		bluesb.set_block_signals(false)
		
		greens.set_block_signals(true)
		greensb.set_block_signals(true)
		greens.value += delta2
		greensb.value += delta2
		greens.set_block_signals(false)
		greensb.set_block_signals(false)

#		blues.set_value_no_signal(blues.value + delta1)
#		greens.set_value_no_signal(greens.value + delta2)
#		blues.value += delta1
#		greens.value += delta2
		
		red_val = reds.value
		green_val = greens.value
		blue_val = blues.value
	elif channel == CHANNEL.GREEN:
		delta = greens.value - green_val
		
		delta1 = -reds.value / (reds.value + blues.value) * delta
		delta2 = -blues.value / (reds.value + blues.value) * delta  
		
		reds.value += delta1
		blues.value += delta2
		
		red_val = reds.value
		green_val = greens.value
		blue_val = blues.value
	else:
		delta = blues.value - blue_val
		
		delta1 = -reds.value / (reds.value + greens.value) * delta
		delta2 = -greens.value / (reds.value + greens.value) * delta  
		
		reds.value += delta1
		greens.value += delta2
		
		red_val = reds.value
		green_val = greens.value
		blue_val = blues.value
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
