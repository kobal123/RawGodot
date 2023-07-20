extends HBoxContainer

var labelText:String = "ááá";

var value_changed_callback = null

func set_value_changed_callback(callable: Callable):
	value_changed_callback = callable



var BUFFER_OWNER_ID: int = 0;
var updates_at_position:int = 0
var IS_DATA_INT:bool = false
var IS_DATA_BOOL:bool = true

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
	var label = %Label
	label.text = labelText


func setup(_labelText: String, checked_: bool):
	labelText = _labelText
#	%CheckBox.set_pressed(checked_)


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

