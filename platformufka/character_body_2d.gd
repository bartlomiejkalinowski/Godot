extends CharacterBody2D

const SPEED = 900.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 900.0
const MAX_JUMPS = 2
const WALL_JUMP_FORCE = Vector2(400, -600)

const DASH_SPEED = 1500
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.5

# Płynne rozpędzanie
const ACCELERATION = 3000.0
const FRICTION = 2500.0

# Sonic Spin Dash
const SPIN_CHARGE_MAX = 3000.0
const SPIN_CHARGE_RATE = 3000.0
const SPIN_RELEASE_DECAY = 2000.0

var spin_charge = 0.0
var is_spin_charging = false
var is_spin_releasing = false

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 0

var is_doublejump = false
var is_wall_jumping = false
var jumps_left = MAX_JUMPS

@onready var wall_check_left = $WallCheckLeft
@onready var wall_check_right = $WallCheckRight


func _physics_process(delta):

	# --- DASH COOLDOWN ---
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# --- DASH RUCH ---
	if is_dashing:
		dash_timer -= delta
		velocity.y = 0
		velocity.x = dash_direction * DASH_SPEED

		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN

	else:
		# --- SPIN DASH ŁADOWANIE ---
		if Input.is_action_pressed("spin") and is_on_floor():
			is_spin_charging = true
			is_spin_releasing = false
			spin_charge = min(spin_charge + SPIN_CHARGE_RATE * delta, SPIN_CHARGE_MAX)
			velocity.x = 0

		# --- SPIN DASH WYPUSZCZENIE ---
		elif Input.is_action_just_released("spin") and is_spin_charging:
			is_spin_charging = false
			is_spin_releasing = true
			var dir = -1 if $AnimatedSprite2D.flip_h else 1
			velocity.x = dir * spin_charge

		# --- SPIN DASH RUCH PO WYPUSZCZENIU ---
		if is_spin_releasing:
			velocity.x = move_toward(velocity.x, 0, SPIN_RELEASE_DECAY * delta)
			if abs(velocity.x) < 50:
				is_spin_releasing = false
				spin_charge = 0

		# --- NORMALNY RUCH (jeśli nie spin dash) ---
		if not is_spin_charging and not is_spin_releasing:
			var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

			if direction != 0:
				velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

		# --- GRAWITACJA ---
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0
			jumps_left = MAX_JUMPS
			is_doublejump = false
			is_wall_jumping = false

		# --- SKOKI ---
		if Input.is_action_just_pressed("ui_accept"):

			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				jumps_left = MAX_JUMPS - 1
				is_wall_jumping = false

			elif wall_check_left.is_colliding():
				velocity = WALL_JUMP_FORCE
				jumps_left = MAX_JUMPS - 1
				is_wall_jumping = true

			elif wall_check_right.is_colliding():
				velocity = Vector2(-WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
				jumps_left = MAX_JUMPS - 1
				is_wall_jumping = true

			elif jumps_left > 0:
				velocity.y = JUMP_VELOCITY
				jumps_left -= 1
				is_doublejump = true
				is_wall_jumping = false

		# --- DASH START ---
		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and !Input.is_action_pressed("spin"):
			var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			dash_direction = direction if direction != 0 else (1 if !$AnimatedSprite2D.flip_h else -1)
			is_dashing = true
			dash_timer = DASH_DURATION


	# --- ANIMACJE ---
	if is_dashing:
		$AnimatedSprite2D.play("Dash")

	elif is_spin_charging:
		$AnimatedSprite2D.play("spin")

	elif is_spin_releasing:
		$AnimatedSprite2D.play("spin")

	elif is_wall_jumping:
		$AnimatedSprite2D.play("wall_jump")

	elif is_doublejump:
		$AnimatedSprite2D.play("Double_Jump")

	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")

	elif velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.play("moving")

	else:
		$AnimatedSprite2D.play("default")


	move_and_slide()
