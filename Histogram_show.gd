extends VBoxContainer

var histogram_scene = preload("res://histogram.tscn")
var foldable_item_scene = preload("res://Foldable_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var histo_foldable = foldable_item_scene.instantiate()
	var histo_script:Script = load("res://histogram.gd")
	var child := TextureRect.new()

	child.set_script(histo_script)
	ComputePipeLineManager.connect("update_histo",Callable(child,"set_data"))
	child.custom_minimum_size = Vector2(256.0, 120.0) 
	histo_foldable.set_label("Histogram")
	histo_foldable.set_checkbox_callback(ComputePipeLineManager.toggle_histogram)
	histo_foldable.checkbox_visible(true)
	histo_foldable.add_item(child)
	add_child(histo_foldable)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
