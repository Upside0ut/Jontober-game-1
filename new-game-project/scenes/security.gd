extends CharacterBody2D


const speed = 5000.0
const JUMP_VELOCITY = -400.0
@export var destination_node: Node2D
@onready var destination: float

var minimum_x: float
var maximum_x: float

var rng = RandomNumberGenerator.new()

var targeting_player: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if destination > global_position.x:
		velocity.x = delta * speed
	elif destination < global_position.x:
		velocity.x = delta * -speed
	move_and_slide()

	if $ray1.is_colliding():
		maximum_x = $ray1.get_collision_point().x
	else:
		maximum_x = global_position.x + 500.0
	
	if $ray2.is_colliding():
		minimum_x = $ray2.get_collision_point().x
	else:
		minimum_x = global_position.x - 500.0
	for n: RayCast2D in [$ray1, $ray2]:
		var player = false
		if n.is_colliding():
			if n.get_collider().name.contains("player_2"):
				destination = n.get_collider().global_position.x
				player = true
		if player:
			targeting_player = true
		else:
			targeting_player = false
	
	$Timer.paused = targeting_player

	
func _on_timer_timeout() -> void:
	get_destination()
	$Timer.wait_time = rng.randf_range(3.0, 6.0)

func get_destination():
	print('new destination')
	destination = rng.randf_range(minimum_x, maximum_x)
