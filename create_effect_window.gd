extends ConfirmationDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_confirmed():
	var effect_list = %EffectItemList
	var imgNode = get_node("/root/Control/HSplitContainer/VSplitContainer/VSplitContainer/myImageNode")
	var effect_panel = get_node("/root/Control/HSplitContainer/Panel/rightSidePanel") 
	var item_text_ = effect_list.get_item_text(effect_list.get_selected_items()[0])
	effect_panel.create_editor_piece(item_text_)
	imgNode.create_effect_layer(item_text_)



func _on_menu_button_pressed():
	if visible:
		hide()
	else:
		show()
