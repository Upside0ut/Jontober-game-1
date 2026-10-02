extends RigidBody2D

const roll_speed = 15
const JUMPING_POWER = -500.0

func _process(delta: float) -> void:
	$floor.global_rotation = 0
	if Input.is_action_pressed("left"): #if going left
		angular_velocity -= delta * roll_speed #roll left
	
	if Input.is_action_pressed("right"): #if going right
		angular_velocity += delta * roll_speed #roll right
	
	if $floor.is_colliding() and Input.is_action_just_pressed("jump"):
		linear_velocity.y = JUMPING_POWER
		get_parent().sounds("jump")
