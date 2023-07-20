extends VBoxContainer

var BUFFER_OWNER_ID = -1

# Called when the node enters the scene tree for the first time.

func setup(buffer_id:int, update_pos_start:int, label:String = "Component", rgb_starts = [1.0, 1.0, 1.0]  ):
	BUFFER_OWNER_ID = buffer_id
	for index in range(2,get_child_count()):
		var child = get_child(index)
		child.set_buffer_owner_id(buffer_id)
		child.set_value_changed_calls(update_pos_start)
		update_pos_start += 1
	
	%Label.text = label
	get_child(2).setup("Red component",-1.0,1.0,0.01,rgb_starts[0])
	get_child(3).setup("Green component",-1.0,1.0,0.01,rgb_starts[1])
	get_child(4).setup("Blue component",-1.0,1.0,0.01,rgb_starts[2])
	material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
