extends Control

var BUFFER_ID: int = -1


func set_buffer_id(id_:int):
	BUFFER_ID = id_

# Called when the node enters the scene tree for the first time.
func _ready():
	%horizontal.connect("pressed", Callable(self,"update_buffer"))
	%vertical.connect("pressed", Callable(self,"update_buffer"))
	CheckBox
	


func update_buffer():
	if BUFFER_ID == -1:
		return
	
	var d: PackedInt32Array = []
	if %horizontal.button_pressed and %vertical.button_pressed:
		d.push_back(3)
	elif %horizontal.button_pressed and !%vertical.button_pressed:
		d.push_back(1)
	elif !%horizontal.button_pressed and %vertical.button_pressed:
		d.push_back(2)
	else:
		d.push_back(0)
	ComputePipeLineManager._update_buffer(BUFFER_ID,d.to_byte_array(),0)
	ComputePipeLineManager.apply_effects()
	ComputePipeLineManager.apply_histo()
	print("UPDATING EDGE BUFFER: ", d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
