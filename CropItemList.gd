extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	AppNodeConstants.get_clip_drawing_overlay().connect("rect_size_changed", Callable(self,"set_width_and_height"))
	

func set_width_and_height(rect: Rect2i):
	%WidthEdit.text = str(rect.size.x)
	%HeightEdit.text = str(rect.size.y)

func _on_item_selected(index):
	if index == 0:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.CUSTOM)
	elif index == 1:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.AS_SHOT)
	elif index == 2:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.FOUR_BY_FIVE)
	elif index == 3:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.SIXTEEN_BY_NINE)
	elif index == 4:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.ONE_BY_ONE)
	elif index == 5:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.FOUR_BY_THREE)
	elif index == 6:
		AppNodeConstants.get_clip_drawing_overlay().set_aspect(CROP.CROP_ASPECT.TWO_BY_THREE)



