extends Control

@export var folder_path := "res://slides/"

var images := []
var index := 0

func _ready():
	load_images_from_folder(folder_path)

func load_images_from_folder(path: String):
	images.clear()
	var dir = DirAccess.open(path)
	if not dir:
		print("Dossier introuvable :", path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var tex = load(path + file_name)
				images.append(tex)
		file_name = dir.get_next()
	dir.list_dir_end()

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
