extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	load_nodes()

func load_nodes():
	var graph_nodes = %NodeContainer.get_children()
	var dir = DirAccess.open("res://")
	var files: PackedStringArray = dir.get_files()
	for file in files:
		if file.begins_with("node__"):
			var scene_res: PackedScene = ResourceLoader.load(file)
			var node_ = scene_res.instantiate()
			%NodeContainer.add_child(node_)
	
	var node_count = %NodeContainer.get_child_count()
	for _child_index in node_count:
		var _child = %NodeContainer.get_child(_child_index)
		for node_string in _child.connections_str:
			for node_index in node_count:
				var __node = %NodeContainer.get_child(node_index)
				if __node == _child:
					continue
				if __node.get_line_edit().text == node_string: 
					_child.connections.append(__node)
				
			


	# If there are many nodes,
	# the actual image loads should be done when the node is "expanded".
	# the actual drawing nodes  and node names should be loaded first, images
	# on demand.

func save_nodes():
	pass
	# each node should have an array of image paths saved with them.
	# the text edit nodes should be saved seperately. The name of these can be the actual
	# name of the node. The name change should be tracked,
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
