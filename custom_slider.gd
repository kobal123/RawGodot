extends VBoxContainer

var BUFFER_OWNER_ID: int = -1;
var updates_at_position:int = 0

func set_buffer_owner_id(buf_id:int):
	BUFFER_OWNER_ID = buf_id
	
func set_buffer_offset(updates_at_pos:int = 0):
	self.updates_at_position = updates_at_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
