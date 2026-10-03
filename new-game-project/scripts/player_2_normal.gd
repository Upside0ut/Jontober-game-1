extends CharacterBody2D

const ROLL_SPEED = 50
const SPEED = 300.0
const JUMP_VELOCITY = -600.0

enum STATES{WALKING, RUNNING, JUMPING, IDLE, ROLLING, FALLING}
var state: STATES

var rng = RandomNumberGenerator.new()
var step_time: float = .4
@export var footstep_sounds: Array[AudioStream]

var dyamite_count: int = 0

var parent: Node2D
func _ready() -> void:
	if get_parent().name == "player_2":
		parent = get_parent()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		state = STATES.JUMPING
		velocity += get_gravity() * delta
	
	if Input.is_action_pressed("left"):
		$normal_state/anim.flip_h = true
	elif Input.is_action_pressed("right"):
		$normal_state/anim.flip_h = false
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		parent.sounds("jump")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * multiplier()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_floor() and direction:
		footsteps(footstep_sounds)
		state = STATES.WALKING
		if Input.is_action_pressed("run"):
			state = STATES.RUNNING
	if is_on_floor() and !direction:
		state = STATES.IDLE
	animations()
	move_and_slide()
	

func multiplier():
	var value: float = 1.0
	match state:
		STATES.WALKING:
			value *= 1.0
		STATES.RUNNING:
			value *= 1.6
		STATES.JUMPING:
			value *= 1.0
		STATES.IDLE:
			value *= 1.0
	if parent.shrunken:
		value /= 2
	return value

func animations():
	match state:
		STATES.WALKING:
			$normal_state/anim.play("walk")
			step_time = .4
		STATES.RUNNING:
			$normal_state/anim.play("run")
			step_time = .2
		STATES.JUMPING:
			$normal_state/anim.play("jump")
		STATES.IDLE:
			$normal_state/anim.play("idle")

func footsteps(sounds):
	if $step_timer.is_stopped() and is_on_floor() and sounds.size() > 0:
		$walk_sound.pitch_scale = rng.randf_range(.95, 1.05)
		$walk_sound.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		$step_timer.wait_time = step_time
		$walk_sound.play()
		$step_timer.start()
