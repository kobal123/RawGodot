extends Panel



var mask_name
var tRect

var basic_style: StyleBoxFlat

var highlight_style = StyleBoxFlat.new()
var light_ = Color(60.0/255.0,60.0/255.0,60.0/255.0,1.0)

var is_selected: bool = false

signal item_clicked(name_: String)


# Called when the node enters the scene tree for the first time.
func _ready():
	mask_name = %Label
	tRect = %TextureRect
	basic_style = get_theme_stylebox("panel")
	highlight_style.set_bg_color(light_)
	add_theme_color_override("CUSTOM COLOR", Color.REBECCA_PURPLE)
	var mask_container = AppNodeConstants.get_mask_scroll_container()
	connect("item_clicked", Callable(mask_container,"make_mask_panel_visible"))
	connect("item_clicked", Callable(MaskDrawingMaster,"set_current_mask"))


func get_mask_name() -> String:
	return mask_name.text

func detach_texture():
	%TextureRect.texture = null

func attach_texture(name:String):
	%TextureRect.texture = MaskDrawingMaster.get_overlay_texture_by_name(name)

func set_mask_preview_texture(texture_: Texture) -> void:
	print(tRect)
	%TextureRect.texture = texture_
	print("TEXTURE FOR MASK PREVIEW IS: ", texture_)
	print("Drawing current mask:", MaskDrawingMaster.get_current_mask())


func set_mask_preview_label(name: String) -> void:
	%Label.text = name


func _on_mouse_entered():
#	if is_selected:
#		return
	add_theme_stylebox_override("panel", highlight_style)
	set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
#	Input.set_custom_mouse_cursor()
	

func _on_mouse_exited():
	if is_selected:
		return
	add_theme_stylebox_override("panel", basic_style)
	set_default_cursor_shape(Control.CURSOR_ARROW)


func _on_gui_input(event):

	
#	print("GUI INPUT")
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("ITEM SELECTED")
				is_selected = true
				add_theme_stylebox_override("panel", highlight_style)
				emit_signal("item_clicked", get_mask_name())

func item_was_clicked(name_):
	print("ITEM WAS SELECTED WITH NAME: ", name_)
	if name_ != mask_name.text:
		print("NAME IS NOT EQUAL TO MINE: ", mask_name.text)
		print("DISABLING HIGHLIGHT BACKGROUND FOR MASK")
		is_selected = false
		add_theme_stylebox_override("panel", basic_style)

