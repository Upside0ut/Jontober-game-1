extends RigidBody2D

const roll_speed = 15

func _process(delta: float) -> void:
	if Input.is_action_pressed("left"): #if going left
		angular_velocity -= delta * roll_speed #roll left
	
	if Input.is_action_pressed("right"): #if going right
		angular_velocity += delta * roll_speed #roll right
