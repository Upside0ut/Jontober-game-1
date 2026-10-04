extends RigidBody2D

const roll_speed = 15
const JUMPING_POWER = -500.0
var max_speed = 800.0

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("run"):
		max_speed = 1000.0
	else:
		max_speed = 800.0
		
	$floor.global_rotation = 0
	$ceiling.global_rotation = 0
	if get_parent().can_move:
		if Input.is_action_pressed("left") and linear_velocity.x > -max_speed: #if going left
			angular_velocity -= delta * roll_speed #roll left
		
		if Input.is_action_pressed("right") and linear_velocity.x < max_speed: #if going right
			angular_velocity += delta * roll_speed #roll right
		
		if $floor.is_colliding() and Input.is_action_just_pressed("jump"):
			linear_velocity.y = JUMPING_POWER
			get_parent().sounds("jump")
	
	if $ceiling.is_colliding():
		get_parent().ceiling = true
	else:
		get_parent().ceiling = false
