extends CharacterBody2D


@export var speed: float = 400.0
@export var jump_velocity: float = -500.0
@export var double_jump_velocity: float = -400.0

@onready var animated_sprit: AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false
var animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air: bool = false
var type_attack: int = 1
var has_attack: bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()
		was_in_air = false
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif not has_double_jumped:
			double_jump()

	if Input.is_action_pressed("attack"):
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction.x != 0:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if not is_on_floor():
			animated_sprit.play("jump_loop")
		else:
			if direction.x != 0:
				animated_sprit.play("run")
			else:
				animated_sprit.play("idle")
		type_attack = 1

func update_facing_direction():
	if direction.x > 0:
		animated_sprit.flip_h = false
		var ref: Vector2 = $Sword/SwordShape2D.position
		$Sword/SwordShape2D.position = Vector2(abs(ref.x), 0)
	elif direction.x < 0:
		animated_sprit.flip_h = true
		var ref: Vector2 = $Sword/SwordShape2D.position
		$Sword/SwordShape2D.position = Vector2(-abs(ref.x), 0)

func jump():
	velocity.y = jump_velocity
	if not animation_locked:
		animation_locked = true
		animated_sprit.play("jump_start")


func double_jump():
	velocity.y = double_jump_velocity
	has_double_jumped = true
	if not animation_locked:
		animation_locked = true
		animated_sprit.play("jump_double")


func land():
	animated_sprit.play("jump_end")
	animation_locked = true

func attack():
	if not has_attack:
		if type_attack == 1:
			animated_sprit.play("attack1")
			type_attack = 2
		else:
			animated_sprit.play("attack2")
			type_attack = 1
		animation_locked = true
		has_attack = true
		$Sword.monitoring = true
		$Sword.visible = true

func _on_animated_sprite_2d_animation_finished():
	if ["jump_start", "jump_end", "jump_double", "attack1", "attack2"].has(animated_sprit.animation):
		animation_locked = false
		has_attack = false
		$Sword.monitoring = false
		$Sword.visible = false
