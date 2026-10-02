extends CharacterBody2D

const ROLL_SPEED = 50
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var speed_multiplier = 1.0

enum STATES{WALKING, RUNNING, JUMPING, IDLE, ROLLING, FALLING}
var state: STATES

var rng = RandomNumberGenerator.new()
var step_time: float = .4
@export var footstep_sounds: Array[AudioStream]

var dyamite_count: int = 0

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
		$sounds/jump.play()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * speed_multiplier
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
	
		
#	dynamite
	if Input.is_action_just_pressed("use") and dyamite_count > 0:
		dyamite_count -= 1
		var dynamite = load("res://scenes/dynamite.tscn")
		var instance: RigidBody2D = dynamite.instantiate()
		get_tree().current_scene.add_child(instance)
		instance.linear_velocity = velocity
		instance.global_position = Vector2($normal_state/position.global_position.x, $normal_state/position.global_position.y - 150)
		instance.explode()
	

func animations():
	match state:
		STATES.WALKING:
			$normal_state/anim.play("walk")
			speed_multiplier = 1.0
			step_time = .4
		STATES.RUNNING:
			$normal_state/anim.play("run")
			speed_multiplier = 1.6
			step_time = .2
		STATES.JUMPING:
			$normal_state/anim.play("jump")
			speed_multiplier = 1.0
		STATES.IDLE:
			$normal_state/anim.play("idle")
			speed_multiplier = 1.0

func footsteps(sounds):
	if $step_timer.is_stopped() and is_on_floor() and sounds.size() > 0:
		$walk_sound.pitch_scale = rng.randf_range(.95, 1.05)
		$walk_sound.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		$step_timer.wait_time = step_time
		$walk_sound.play()
		$step_timer.start()


func _on_interact_area_entered(area: Area2D) -> void:
	if area.name == "dynamite_pickup":
		if area.get_parent().can_pickup:
			dyamite_count += 1
			area.get_parent().queue_free()
