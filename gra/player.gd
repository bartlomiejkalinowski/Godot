extends CharacterBody2D


const SPEED = 400
const JUMP_FORCE = -700
const GRAVITY = 700
const MAX_JUMPS = 2
const WALL_JUMP_FORCE = Vector2(2000, -600)
const DASH_SPEED = 1000
const DASH_DURATION = 0.2  # sekundy
const DASH_COOLDOWN = 0.5  # sekundy

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 0



var jumps_left = MAX_JUMPS

@onready var wall_check_left = $WallCheckLeft
@onready var wall_check_right = $WallCheckRight

signal double_jump


func _physics_process(delta):
	# Cooldown

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Dash aktywny
	if is_dashing:
		dash_timer -= delta
		velocity.y = 0  # zatrzymanie grawitacji
		velocity.x = dash_direction * DASH_SPEED

		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN
			# Wybierz animację zależnie od ruchu
			

	else:
		# Aktywacja dasha
		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
			dash_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			if dash_direction != 0:
				is_dashing = true
				dash_timer = DASH_DURATION

	if not is_dashing:
		var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		velocity.x = direction * SPEED
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0
			jumps_left = MAX_JUMPS

		if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
			velocity.y = JUMP_FORCE
			jumps_left -= 1
			emit_signal("double_jump")
		# Grawitacja
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0
			jumps_left = MAX_JUMPS

		# Skok
	# Skok
		if Input.is_action_just_pressed("ui_accept"):
			if is_on_floor():
				velocity.y = JUMP_FORCE
				jumps_left = MAX_JUMPS - 1  # pierwszy skok
			elif jumps_left > 0:
				velocity.y = JUMP_FORCE
				jumps_left -= 1
			elif wall_check_left.is_colliding():
				velocity.x = WALL_JUMP_FORCE.x
				velocity.y = WALL_JUMP_FORCE.y
				jumps_left = MAX_JUMPS - 1  # reset po wall jumpie
			elif wall_check_right.is_colliding():
				velocity.x = -WALL_JUMP_FORCE.x
				velocity.y = WALL_JUMP_FORCE.y
				jumps_left = MAX_JUMPS - 1  # reset po wall jumpie
	
			emit_signal("double_jump") 
	 # pokazuje animację biegu
	move_and_slide()

func _on_lava_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
var is_double_jumping := false


func _on_area_2d_12_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_spawn_point_child_entered_tree(node: Node) -> void:
	pass # Replace with function body.
