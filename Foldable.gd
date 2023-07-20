extends VBoxContainer

var item_scene = preload("res://Foldable_item.tscn")

var a = preload("res://channel_mixer_component.tscn")
var total_height:int


func _ready():
	pass

#func _ready():
#	pass
	#add_element("channel mixer", a.instantiate())
	#get_child(0).add_item(a.instantiate())
	
#	var item = item_scene.instantiate()
#	item.set_label("second foldable")
#	get_child(0).add_item(item)
#
#	#element.hide()
#	#element.set_size(self.size)
#	item.add_item(a.instantiate())
#	size = item.size
#	item.set_signal_for_parent(self)
	
	#get_child(0).add_item(a.instantiate())


func remove_height(height:int):
	print("rmove height")
	size = Vector2(size.x,size.y - height)

func add_height(height:int):
	print("add height")
	size = Vector2(size.x,size.y + height)


func add_element(label: String, element: Control):
	var item = item_scene.instantiate()
	item.set_label(label)
	add_child(item)
	
	#element.hide()
	#element.set_size(self.size)
	item.add_item(element)
	size = item.size
	item.set_signal_for_parent(self)
