extends Button

signal code_changed(editor_name: String, id, _text: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("code_changed", Callable(CustomShaderParser, "parse"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _pressed():
	var parent = get_parent()
	emit_signal("code_changed", parent.editor_name, parent.id, parent.text)
