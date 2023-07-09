extends CharacterBody2D

@export var player = 1
@export var pourcent = 0
@export var speed: float = 400.0
@export var jump_velocity: float = -500.0
@export var double_jump_velocity: float = -400.0

@onready var animated_sprit: AnimationPlayer = $AnimationPlayer

signal signal_hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false
var animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air: bool = false
var type_attack: int = 1
var has_attack: bool = false

var JUMP
var LEFT
var RIGHT
var DOWN
var ATTACK

func _ready():
	if player == 1:
		JUMP = "p1_jump"
		LEFT = "p1_left"
		RIGHT = "p1_right"
		DOWN = "p1_down"
		ATTACK = "p1_attack"
	elif player == 2:
		JUMP = "p2_jump"
		LEFT = "p2_left"
		RIGHT = "p2_right"
		DOWN = "p2_down"
		ATTACK = "p2_attack"

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
	if Input.is_action_just_pressed(JUMP):
		if is_on_floor():
			jump()
		elif not has_double_jumped:
			double_jump()

	if Input.is_action_pressed(ATTACK):
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector(LEFT, RIGHT, JUMP, DOWN)
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
		$Sprite2D.set_scale(Vector2(2,2))
		var pos_shape1: Vector2 = $Sword/SwordShapeAttack1.position
		var pos_shape2: Vector2 = $Sword/SwordShapeAttack2.position
		$Sword/SwordShapeAttack1.position = Vector2(abs(pos_shape1.x), pos_shape1.y)
		$Sword/SwordShapeAttack2.position = Vector2(abs(pos_shape2.x), pos_shape2.y)
		
	elif direction.x < 0:
		$Sprite2D.set_scale(Vector2(-2,2))
		var pos_shape1: Vector2 = $Sword/SwordShapeAttack1.position
		var pos_shape2: Vector2 = $Sword/SwordShapeAttack2.position
		$Sword/SwordShapeAttack1.position = Vector2(-abs(pos_shape1.x), pos_shape1.y)
		$Sword/SwordShapeAttack2.position = Vector2(-abs(pos_shape2.x), pos_shape2.y)
		

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

func hit(damage):
	pourcent += damage
	signal_hit.emit(self.name, pourcent)


func _on_animation_player_animation_finished(anim_name):
	if ["jump_start", "jump_end", "jump_double", "attack1", "attack2"].has(anim_name):
		animation_locked = false
		has_attack = false
