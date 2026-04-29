extends AnimatedSprite2D
@onready var input = get_node("Player")  # lub "Path/To/PlayerInput" # lub ścieżka do node'a emitującego sygnał
@onready var strona = -1

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		if strona == 1:
			play("jump")
		elif strona == 0:
			play("jump_right")
	elif Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("dash"):
			play("dash_left")
		else:
			play("left")
		strona = 0
	elif Input.is_action_pressed("ui_right"):
		if Input.is_action_pressed("dash"):
			play("dash_right")
		else:
			play("right")
		strona = 1
	else:
		if Input.is_action_just_released("ui_left"):
			play("default_left")
		elif Input.is_action_just_released("ui_right"):
			play("default_right")
