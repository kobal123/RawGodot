extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var histo_script:Script = load("res://histogram.gd")
	var child := TextureRect.new()
	child.size = Vector2(0,0)

	child.set_script(histo_script)
	ComputePipeLineManager.connect("update_histo",Callable(child,"set_data"))
	%HBoxContainer.add_item(child)
	%HBoxContainer.set_label("Histgram")
	%HBoxContainer.checkbox_visible(true)
#	%HBoxContainer.set_padding(25)


