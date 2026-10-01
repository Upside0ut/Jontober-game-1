extends RigidBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var rollsound: AudioStreamPlayer2D = $rollsound
@onready var bounce: AudioStreamPlayer = $Bounce
@onready var jump: AudioStreamPlayer = $jump



#i'm not used to working in teams, hopefully these comments are enough! - UpsideOut
const roll_speed = 50
const  jump_force = -800
var allow_jump = false 
var dead = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	if ray_cast_2d.is_colliding(): #check if player is on the floor
		allow_jump = true
		
		if !rollsound.playing: #replay roll sound from beginning
			rollsound.play()
		rollsound.pitch_scale = abs(linear_velocity.x) / 500 + 0.01 #scale pitch of roll sound
		rollsound.volume_linear = abs(linear_velocity.x) / 500 #scale volume of roll sound
	else:
		rollsound.volume_linear = 0.0
	
	ray_cast_2d.global_rotation = 0
	
	if Input.is_action_pressed("left"): #if going left
		angular_velocity -= delta * roll_speed #roll left
	
	if Input.is_action_pressed("right"): #if going right
		angular_velocity += delta * roll_speed #roll right
	
	if Input.is_action_just_pressed("jump") and allow_jump: #checks if conditions are right to jump
		allow_jump = false #stop double jumping
		jump.play()
		linear_velocity.y = jump_force #apply jump force
	
	
	if dead:
		rotation = 0
		freeze = true
		lock_rotation = true


func _on_hitbox_spikes_area_entered(area: Area2D) -> void:
	if area.name == "spikes":
		dead = true
		$Explosion.play()
		$AnimationPlayer.play("die")
		await $AnimationPlayer.animation_finished
		if get_tree() != null:
			get_tree().reload_current_scene()
	
	if area.name == "goal":
		
		get_tree().change_scene_to_file(Global.levels[Global.level])
		Global.level += 1


func _on_body_entered(body: Node) -> void: #when colliding with the ground
	bounce.pitch_scale = randf_range(0.8,1.1)
	bounce.volume_linear = abs(linear_velocity.x + linear_velocity.y) / 1000 + 0.01
	bounce.play()
