extends Control

@export var folder_path := "res://slides/"
@onready var screen = $Screen

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
	var files := []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	# Trier les fichiers par ordre alphabétique
	files.sort()  

	# Charger les textures dans l’ordre
	for f in files:
		images.append(load(path + f))


func open():
	visible = true
	index = 0
	_update_image()
	
func close():
	visible = false

func _update_image():
	screen.texture = images[index]

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
