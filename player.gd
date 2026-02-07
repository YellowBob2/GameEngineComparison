extends CharacterBody2D

@export var speed := 200.0
@export var jump_velocity := -300.0
@export var gravity := 1200.0

@onready var cat: AnimatedSprite2D = $Cat

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left/right
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

	_update_anim(dir)

func _update_anim(dir: float) -> void:
	# Flip
	if dir != 0:
		cat.flip_h = dir < 0

	# Air animations
	if not is_on_floor():
		if velocity.y < 0.0:
			_play_if_changed("jump")
		else:
			_play_if_changed("fall")
		return

	# Ground animations
	if abs(dir) > 0.01:
		_play_if_changed("run")
	else:
		_play_if_changed("idle")

func _play_if_changed(name: String) -> void:
	if cat.animation != name:
		cat.play(name)
