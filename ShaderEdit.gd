extends CodeEdit


@export var editor_name: String = "Custom effect"
@export var id: int = 0

func set_id(id_: int):
	id = id_

func set_editor_name(name_: String):
	editor_name = name_


var font_size__ = 15
# Called when the node enters the scene tree for the first time.
func _ready():
	InputMap.load_from_project_settings()
	code_completion_prefixes.append("vec")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	
	if event.is_action_pressed("CONTROL_SCROLL_DOWN"):
		font_size__ -= 1
		add_theme_font_size_override("font_size", font_size__)
	elif event.is_action_pressed("CONTROL_SCROLL_UP"):
		font_size__ += 1
		add_theme_font_size_override("font_size", font_size__)
