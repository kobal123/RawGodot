extends VBoxContainer

signal collapsed_items(height: int)
signal opened_items(height: int)

var arrow_right = preload("res://lil_arrow.png")
var arrow_down = preload("res://lil_arrow_down.png")



func _ready():
	add_to_group("FOLDABLE")

	if not arrow_disabled:
		%TextureRect.texture = arrow_right
		%TextureRect.flip_h = true

	if get_child_count() > 2:
		for index in range(2,get_child_count()):
			var child := get_child(index)
			remove_child(child)
			add_item(child)
			
	



var arrow_disabled = false

func disable_arrow():
	%TextureRect.texture = null
	arrow_disabled = true

func checkbox_visible(visibility:bool):
	%CheckBox.visible = visibility

func set_checkbox_callback(callback, arg = null):
	print("SETTING CHECKBOX CALLBACK: ", callback, ", arg: ", arg)
	%CheckBox.set_callback(callback, arg)

func set_label(text: String):
	Image
	%Label.text = text

func set_signal_for_parent(parent_element: Control):
	return
	connect("collapsed_items",Callable(parent_element,"remove_height"))
	connect("opened_items",Callable(parent_element,"add_height"))

func add_item(element: Control):
	var margincontainer = MarginContainer.new()
	margincontainer.add_theme_constant_override("margin_left", 5)
	margincontainer.add_theme_constant_override("margin_right", 5)
	margincontainer.add_child(element)
	%items.add_child(margincontainer)

func get_child_from_items(index: int):
	return %items.get_child(index).get_child(0)

func get_children_from_items() -> Array[Control]:
	var _children: Array[Control] = []
	
	for c in %items.get_children():
		_children.append(c.get_child(0))
	return _children

func toggle_items_visibility():
	%items.visible = !%items.visible 
	if %TextureRect.texture == arrow_right:
		%TextureRect.texture = arrow_down
	else:
		%TextureRect.texture = arrow_right



func _can_drop_data(_position: Vector2, data) -> bool:
	var can_drop = data is Node and data.is_in_group("DRAGGABLE")

	if can_drop:
	
		var _index_ = 0
		var _found_data_index = 0
		var _closest_child_index = 0
		for d in %items.get_children():
			var c = d.get_child(0)
			
			if data == c:
	#			print("FOUND CHILD")
				_found_data_index = _index_


			if abs((_index_ + 1) * c.size.y - _position.y + %Container.size.y) < 40.0:	
				_closest_child_index =_index_
			_index_ += 1
#		print("CLOSEST INDEX: ", _closest_child_index)
		# during drag the element is transparent, here
		# we change that back

		%items.move_child(%items.get_child(_found_data_index),_closest_child_index)

	return can_drop



func _drop_data(_position: Vector2, data) -> void:
	
#	print("target drop data has run, dropping at pos: ", _position)
	var _index_ = 0
	var _found_data_index = 0
	var _closest_child_index = 0
	for d in %items.get_children():
		var c = d.get_child(0)
		
		if data == c:
#			print("FOUND CHILD")
			_found_data_index = _index_

		print(abs((_index_ + 1) * c.size.y - _position.y + %Container.size.y))
		if abs((_index_ + 1) * c.size.y - _position.y + %Container.size.y) < 40.0:	
			_closest_child_index =_index_
		_index_ += 1
#	print("CLOSEST INDEX: ", _closest_child_index)
	# during drag the element is transparent, here
	# we change that back
	data.modulate.a = 1
	print("DROPPED ELEMENt")
	if _closest_child_index > %items.get_child_count() -1:
		_closest_child_index = %items.get_child_count() -1;
	%items.move_child(%items.get_child(_found_data_index), _closest_child_index)
#	emit_signal("index_changed_for_effect",_found_data_index,_closest_child_index)


func set_padding(padding_size: int):
	%PaddingElement.custom_minimum_size = Vector2(40.0, 10.0)




