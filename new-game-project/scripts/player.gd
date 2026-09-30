extends RigidBody2D

#i'm not used to working in teams, hopefully these comments are enough! - UpsideOut

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"): #if going left
		angular_velocity -= delta * 50 #roll left
	if Input.is_action_pressed("right"): #if going right
		angular_velocity += delta * 50 #roll right
	if Input.is_action_just_pressed("jump"):
		
		linear_velocity.y = -800 #apply jump force
