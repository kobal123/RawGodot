extends Control


var line = null
var is_drawing = false
var is_dragging = false
var line_end: Vector2

var connections: Array[Node] = []

@export var connections_str: Array[String] = []

@export var line_edit_text: String = ""
# only true if line edit text changed or is the empty string


var first_created: bool = false;

var file_name_prefix: String = "node__"

var index = 0
var start_point = Vector2()
var end_point = Vector2()
var _circle_color: Color = Color.RED



func set_circle_color(color: Color):
	_circle_color = color


func get_line_edit():
#	return %LineEdit
	return get_child(0)
	

func get_editor():
#	return %ColorRect
	return get_child(1)

func _input(event):

	if event.is_action_released("CONTROL_MIDDLE_BUTTON"):
		is_dragging = false
	
	if event.is_action_released("CONTROL_MOUSE_LEFT"):
		is_drawing = false
	
	if event is InputEventMouseButton:
		if abs(event.position.x - (position.x + __size.x/2.0)) < 150 and abs(event.position.y - (position.y + - __size.y/2.0)) < 150: 
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
				line_end = event.position
				start_point = self.position
				end_point = get_global_mouse_position()
				is_drawing = true
#				print("MOUSE EVENT HAPPENED")

#			elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
#				is_drawing = false # Stop drawing
#				line_end = position


			elif event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE:
				is_dragging = true
			elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE:
				is_dragging = false
			
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
				var c = get_child(1)
				c.visible = not c.visible
				#%ColorRect.visible = not %ColorRect.visible
#		else:
#			print("pos ", abs(event.position.x - position.x))
#			print("event pos ", event.position.x)
#			print("current pos ", position.x)
	if is_dragging:
		var glob_pos = get_global_mouse_position()
		self.position = glob_pos - __size / 2.0# - (glob_pos - self.position)#event.global_position - Vector2(15,15)
		global_circle_center = self.position + __size/2.0 + Vector2(0,circle_offset_y)
		queue_redraw()
	if event is InputEventMouseMotion:
#		if not event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE:
#			is_dragging = false
			
		if is_drawing:
#			print("MOUSE MOTION EVENT HAPPENED")
			queue_redraw()
			line_connects_to_node(get_global_mouse_position())

	if event is InputEventMouseButton and not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_drawing = false # Stop drawing
		line_end = Vector2.ZERO
		queue_redraw()
	
	
#	PerfTimer.mse(s, "NODE INPUT FUCTION")


func line_connects_to_node(pos):
#	return
	var s = PerfTimer.mss()
	var node_to_connect = self.get_parent().get_parent().child_at_position(pos)
	if node_to_connect != null:
		print("NODE TO CONNECT: ", node_to_connect.get_line_edit().text)
	else:
		print("NODE TO CONNECT: ", node_to_connect)
	print("SELF: ", get_line_edit().text)
	print("_----------------------------------------")
	if node_to_connect == null or node_to_connect == self:
#		print("Node was null")
		return
#	print("Added connection")
	if not connections.has(node_to_connect):
		connections.push_back(node_to_connect)
		is_drawing = false # Stop drawing
		line_end = Vector2.ZERO
		queue_redraw()
	PerfTimer.mse(s, "NODE CONNECTS TO NODE")

var __size = Vector2(150, 150)

var radius
var circle_offset_y = 0



var circle_center = __size/2.0 + Vector2(0,circle_offset_y)
var global_circle_center = position + __size/2.0 + Vector2(0,circle_offset_y)

func _save_connections():
	connections_str.clear()
	for _node in connections:
		print("NODE WAS CONNECTED TO: ", _node.get_line_edit().text)
		connections_str.append(_node.get_line_edit().text)


func _draw():
#	self.get_parent().queue_redraw()
#	draw_circle(__size/2.0 + Vector2(0,-30), %LineEdit.__size.x/2.0, Color.RED)
	draw_circle(circle_center, radius, _circle_color)

	if is_drawing:
		draw_line(circle_center, get_global_mouse_position() - position, Color.RED)
#	for node in connections:
#		draw_line(__size/2.0, node.global_position - position + node.__size/2.0, Color.RED)
#	print("Lineend: ", line_end)
#	print("pos: ", position)
#	draw_arc(%LineEdit.__size/2.0, %LineEdit.__size.x/2.0 + 4,0,360,1000,Color.RED,2)

func _ready():
	radius = __size.x/2.0
	
#	if ResourceLoader.exists("res://savegame3.tscn"):
#		remove_child(get_child(1))
#
#		var scene_: PackedScene = ResourceLoader.load("res://savegame3.tscn")
#
#		if scene_.can_instantiate():
#			print("LOADED SCENE ")
#			var node_ = scene_.instantiate()
#			self.add_child(node_)
#	else:
#		print("SCENE DOES NOT EXIST")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_connections()
		var should_rename_existing_file: bool = false
		
		if line_edit_text == "": # this is the first time the node is created
			line_edit_text = get_line_edit().text

			should_rename_existing_file = false
		elif line_edit_text != "" and line_edit_text != get_line_edit().text:
			should_rename_existing_file = true
		
		var text_edit_: ImageTextEdit = get_editor()
		if text_edit_.has_text_changed:
			text_edit_.images.clear()
			text_edit_.img_positions.clear()
			for line_ in text_edit_.get_line_count():
				var line_images = text_edit_.get_images(line_);
				for image in line_images:
					var texture_: TextImageTexture = image as TextImageTexture
					text_edit_.images.append(texture_.get_image())
					text_edit_.img_positions.append(Vector2(texture_.get_line_col()))
		
		var packed = PackedScene.new()
		
		self.owner = get_parent()
		var pack_error = packed.pack(self)
		if pack_error != OK:
			print("THERE WAS AN ERROR PACKING THE SCENE")
			return

		var file_name = get_node_file_name()
		if file_name == "":
			print("GIVE A NAME TO THE NODE")
			return
		
		# the name of the node changed, the old file should be renamed to the current file
		if should_rename_existing_file:
			#get file
			#rename to file_name
			var dir = DirAccess.open("res://")
			dir.rename(get_node_file_name(line_edit_text), file_name)

		file_name = "res://" + file_name
		line_edit_text = get_line_edit().text
		var save_error = ResourceSaver.save(packed, file_name)

		if save_error != OK:
			print("THERE WAS AN ERROR SAVING THE SCENE")
		print("EXITING")

		get_tree().quit() # default behavior

func get_node_file_name(file_: String = ""):
	if file_ == "":
			
		var _editor = get_line_edit()
		if _editor == null:
			return
		var file_name: String = file_name_prefix + _editor.text
		file_name = file_name.lstrip(" ").rstrip(".").replace(" ", ".")
		var i = 0;
		
#		while true:
#			if ResourceLoader.exists(file_name + ".tscn"):
#				file_name += str(i)
#				continue
#			break
		file_name += ".tscn"
		return file_name
	else:
		return file_.lstrip(" ").rstrip(".").replace(" ", ".") + ".tscn"
	
	
	
	
	
	
	
	
	
	
