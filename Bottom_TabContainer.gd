extends TabContainer

var shader_editor_scene = preload("res://custom_shader_edit_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_tab_title(0, "Previews")
	set_tab_title(1, "Custom effect")
	set_tab_title(2, "+")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var tab_before_adding = 0

func _on_tab_selected(tab):
	if tab == get_child_count() -1:
		print("ÁÁÁÁÁÁÁÁÁ")
		current_tab = tab_before_adding
		var new_editor = shader_editor_scene.instantiate()
		new_editor.set_id(ComputePipeLineManager.get_custom_effects_num())
		add_child(new_editor)
		move_child(new_editor, get_child_count() -2)
		set_tab_title(get_child_count() -2, "Custom effect")
		
	else:
		tab_before_adding = tab
