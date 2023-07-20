extends ColorRect

var graph_node = preload("res://graph_node.tscn")



func _ready():
	var s = OS.get_static_memory_usage()
	test()
	var e = OS.get_static_memory_usage()
	
	print("MEMORY USAGE: ", (e - s)/1000000)
	
	
func child_at_position(pos: Vector2) -> Node:
#	var s = PerfTimer.mss()
	for c in %NodeContainer.get_children():
		#print("Node pos: ", c.position,"  pos: ", pos)
		if abs(c.position.x - pos.x) < 150 and abs(c.position.y - pos.y) < 150:
#			PerfTimer.mse(s, "Child_at found")
			
			return c
#	PerfTimer.mse(s, "Child_at None found")
	return null

func _input(event):

	queue_redraw()
#var line = Line2D.new()
var lines = PackedVector2Array()
func _draw():
#	print("DRAW FUNCTION CALLED0")

	var s = PerfTimer.mss()
#	line.clear_points()
#	var total = 0

#	var map = []
	var counter = 0
	var inner_counter = 0
	for index in range(0, %NodeContainer.get_child_count(),1):
		var c = %NodeContainer.get_child(index)
#		var ss = PerfTimer.mss()
		counter += 1
		var pos_from_node = c.position + c.size/2.0 + Vector2(0,c.circle_offset_y)
#		map[c.index] = index
		for c_child in c.connections:
#			draw_line(pos_from_node, c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y),Color.BLUE)
#				
			inner_counter +=1
			lines.push_back(pos_from_node)
			lines.push_back(c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y))
			lines.push_back(pos_from_node)


#			line.add_point(pos_from_node)
#			line.add_point(c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y))
#			line.add_point(pos_from_node)
#			total += 1
#			lines[index] = c.position + c.size/2.0 + Vector2(0,c.circle_offset_y)
#			lines[index + 1] = c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y)
#			lines.push_back(c.position + c.size/2.0 + Vector2(0,c.circle_offset_y))
			
#			lines[index] = pos_from_node
#			lines[index + 1] = c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y)
#			lines.push_back(pos_from_node)
#			lines.push_back(c_child.position + c_child.size/2.0 + Vector2(0,c_child.circle_offset_y))
#		PerfTimer.mse(ss, "Singe connections")
	
	draw_polyline(lines, Color.BLUE)

#	draw_multiline(lines, Color.RED, 2)
	lines.clear()
#	print("loop ran ", total, " times")
#	PerfTimer.mse(s, "MAIN SCENE DRAW")

#	print("COUNTER: ", counter)
#	print("INNER COUNTER: ", inner_counter)
#	print("lines: ", lines)

func _on_button_pressed():
	var node = graph_node.instantiate()
	node.position = size/2.0
	%NodeContainer.add_child(node)



var my_seed = "Godot Rocks".hash()

var item_count = 0
func test():
	seed(my_seed)
	var a = PackedScene.new()

	for i in item_count:
		var node = graph_node.instantiate()
		node.index = get_child_count()
		node.position = Vector2(randf_range(0,100.0),randf_range(0,1000.0))
		%NodeContainer.add_child(node)
	for i in item_count:
		var child = %NodeContainer.get_child(i)
		for k in range(i, min(item_count, item_count)):
			child.connections.push_back(%NodeContainer.get_child(k))


func _on_line_edit_text_changed(new_text: String):
	if new_text.length() < 3:
		return
	
#
	for _child in %NodeContainer.get_children():
		if _child.get_line_edit().text.contains(new_text):
			print("FOUND NODE!!!")
			_child.set_circle_color(Color.GREEN)
			_child.queue_redraw()
		else:
			_child.set_circle_color(Color.RED)
			_child.queue_redraw()


func _on_node_text_search_text_changed(new_text):
	if new_text.length() < 3:
		return
	
#
	
	for _child in %NodeContainer.get_children():
		var s = PerfTimer.mss()
		if _child.get_editor().text.contains(new_text):
			print("FOUND NODE!!!")
			_child.set_circle_color(Color.GREEN)
			_child.queue_redraw()
		else:
			_child.set_circle_color(Color.RED)
			_child.queue_redraw()
		PerfTimer.mse(s, "TEXT CONTAINS CHECK TOOK")
