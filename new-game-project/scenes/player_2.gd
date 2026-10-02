extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum STATES{WALKING, RUNNING, JUMPING, IDLE, CROUCHING}
var state: STATES

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		state = STATES.JUMPING
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("left"):
		$anim.flip_h = true
	elif Input.is_action_just_pressed("right"):
		$anim.flip_h = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_floor() and direction:
		state = STATES.WALKING
	if is_on_floor() and !direction:
		state = STATES.IDLE
	animations()
	move_and_slide()

func animations():
	match state:
		STATES.WALKING:
			$anim.play("walk")
		STATES.JUMPING:
			$anim.play("jump")
		STATES.IDLE:
			$anim.play("idle")

func footsteps():
	pass
