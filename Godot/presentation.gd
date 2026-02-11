extends Control

@onready var slide_rect: TextureRect = $Slide
@export var slide_folder: String = "res://slides"

var slide_paths: PackedStringArray = []
var index := 0

func _ready() -> void:
	# Make sure the UI fills the window (in case you forgot Layout → Full Rect)
	set_anchors_preset(Control.PRESET_FULL_RECT)

	slide_paths = _gather_slide_paths(slide_folder)
	slide_paths.sort()

	if slide_paths.is_empty():
		push_error("No slides found in %s" % slide_folder)
		return

	_show_slide(0)

func _unhandled_input(event: InputEvent) -> void:
	if slide_paths.is_empty():
		return

	# Next slide: Right arrow / Space / PageDown
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_page_down"):
		_show_slide(index + 1)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_show_slide(index + 1)

	# Previous slide: Left arrow / PageUp
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_page_up"):
		_show_slide(index - 1)

	# Quit
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _show_slide(new_index: int) -> void:
	index = clamp(new_index, 0, slide_paths.size() - 1)

	var tex := load(slide_paths[index]) as Texture2D
	if tex == null:
		push_error("Failed to load slide: %s" % slide_paths[index])
		return

	slide_rect.texture = tex

func _gather_slide_paths(folder: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var dir := DirAccess.open(folder)
	if dir == null:
		push_error("Cannot open folder: %s" % folder)
		return out

	dir.list_dir_begin()
	while true:
		var f := dir.get_next()
		if f == "":
			break
		if dir.current_is_dir():
			continue
		var lower := f.to_lower()
		if lower.ends_with(".png") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp"):
			out.append(folder.path_join(f))
	dir.list_dir_end()
	return out
