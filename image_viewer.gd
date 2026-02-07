extends Control

@export var images: Array[Texture2D]

var index := 0

func open():
	visible = true
	index = 0
	_update_image()
	
func close():
	visible = false

func _update_image():
	$TextureRect.texture = images[index]

func _unhandled_input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_right"):
		index = min(index + 1, images.size() - 1)
		_update_image()

	elif event.is_action_pressed("ui_left"):
		index = max(index - 1, 0)
		_update_image()

	elif event.is_action_pressed("ui_cancel"):
		close()
