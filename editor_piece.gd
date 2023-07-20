extends Control

var labelText:String = "ááá";
var min_value = 0;
var max_value = 1;
var step = 1;
var value = 1;

var ID: String;

var value_changed_callback = null

func set_value_changed_callback(callable: Callable):
	value_changed_callback = callable



var BUFFER_OWNER_ID: int = 0;
var updates_at_position:int = 0
var IS_DATA_BOOL = false
func set_data_type(d_type: String):
	if d_type == "float":
		self.IS_DATA_INT = false
	elif d_type == "int":
		self.IS_DATA_INT = true
	elif d_type == "bool":
		self.IS_DATA_BOOL = true

var IS_DATA_INT: bool = false
# Called when the node enters the scene tree for the first time.

var transform_function: Callable


func set_buffer_owner_id(buf_id:int):
	BUFFER_OWNER_ID = buf_id
	
func set_value_changed_calls(updates_at_pos:int = 0, is_data_int:bool = false ):
	self.updates_at_position = updates_at_pos
	self.IS_DATA_INT = is_data_int
#	hslider.connect("change_buffer",Callable(ComputePipeLineManager,"_update_buffer"))
#	sbox.connect("change_buffer",Callable(ComputePipeLineManager,"_update_buffer"))

func _ready():
	add_to_group("DRAGGABLE")
	var label = %funcLabel
	label.text = labelText

	var hslider = %HSlider
	var sbox = %SpinBox
	var imgNode = get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/Control2/myImageNode")
	#progressb.connect("value_changed",Callable(imgNode,"set"+labelText))
	
	hslider.step = step;
	hslider.min_value = min_value
	hslider.max_value = max_value
	hslider.value = value
	sbox.step = step;
	sbox.value = value
	sbox.min_value = min_value
	sbox.max_value = max_value

	hslider.connect("value_changed_with_group",Callable(imgNode,"_set"+labelText))
	sbox.connect("value_changed_with_group",Callable(imgNode,"_set"+labelText))
#
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func set_id(_id: String):
	ID = _id

func setup(_labelText: String, _min = 0.0, _max=100.0, _step = 0.1, _val = 0.0):
	labelText = _labelText
	min_value = _min
	max_value = _max
	step = _step
	value = _val



func _get_drag_data(_position: Vector2):
	AppNodeConstants.get_root().set_currently_dragged_item(self)
	print("get_drag_data has started")
	set_drag_preview(_get_preview_control())
	modulate.a = 0
	return self




func _get_preview_control() -> Control:
	var dup = self.duplicate(0)
	dup.size = size
	
	return dup



func set_transformation_function(fun: Callable):
	transform_function = fun;



func checkbox_visible(visibility:bool):
	%CheckBox.visible = visibility

func set_checkbox_callback(callback, arg = null):
	%CheckBox.set_callback(callback, arg)

