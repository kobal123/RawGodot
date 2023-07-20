extends TabBar


# Called when the node enters the scene tree for the first time.


func _on_tab_hovered(tab):
	pass

func _on_tab_selected(tab):
	pass


func _on_tab_button_pressed(tab):
	pass


func _on_tab_clicked(tab):
	print("TAB PRESSED")
	if tab == 1:
		%ScrollContainer.visible = false
		%MaskScrollContainer.visible = true
		%CropScrollContainer.visible = false
	elif tab == 2:
		%ScrollContainer.visible = false
		%MaskScrollContainer.visible = false
		%CropScrollContainer.visible = true
	else:
		%ScrollContainer.visible = true
		%MaskScrollContainer.visible = false
		%CropScrollContainer.visible = false
