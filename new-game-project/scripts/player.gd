extends RigidBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

#i'm not used to working in teams, hopefully these comments are enough! - UpsideOut
const roll_speed = 50
const  jump_force = -800
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"): #if going left
		angular_velocity -= delta * roll_speed #roll left
	if Input.is_action_pressed("right"): #if going right
		angular_velocity += delta * roll_speed #roll right
	if Input.is_action_just_pressed("jump") and ray_cast_2d.is_colliding(): #checks if conditions are right to jump
		
		linear_velocity.y = jump_force #apply jump force
