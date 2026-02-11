extends Node2D

@onready var prompt = $Prompt
@export var image_viewer: Control

var base_y := 0.0

func _ready():
	hide_prompt()
	base_y = prompt.position.y

func _process(delta):
	if prompt.visible:
		prompt.position.y = base_y + sin(Time.get_ticks_msec() * 0.005) * 2

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		show_prompt()

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		hide_prompt()

func show_prompt():
	prompt.visible = true
	prompt.modulate.a = 0.0
	prompt.scale = Vector2(0.9, 0.9)

	var tween = create_tween()
	tween.tween_property(prompt, "modulate:a", 1.0, 0.15)
	tween.tween_property(prompt, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_prompt():
	var tween = create_tween()
	tween.tween_property(prompt, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func():
		prompt.visible = false
	)

func _input(event):
	if prompt.visible and Input.is_action_just_pressed("interact"):
		image_viewer.open()
