extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	editable = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _gui_input(event):
	if event.is_action_pressed("double_click"):
		editable = !editable
	if event.is_action_pressed("ui_text_completion_accept"):
		release_focus()
	if event.is_action_pressed("ui_text_clear_carets_and_selection"):
		release_focus()
		
func _on_text_change_rejected(rejected_substring):
	editable = false


func _on_focus_exited():
	editable = false
