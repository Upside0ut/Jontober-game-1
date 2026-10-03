extends RigidBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var rollsound: AudioStreamPlayer2D = $rollsound
@onready var bounce: AudioStreamPlayer = $Bounce
@onready var jump: AudioStreamPlayer = $jump

# situational stuff
@export var plinko_pad : CanvasLayer

#i'm not used to working in teams, hopefully these comments are enough! - UpsideOut
const roll_speed = 50
const  jump_force = -800
#var allow_jump = false 
var dead = false
# has_dynamite becomes true when the player enters a dynamite pickup area
var has_dynamite = false

#key names for config file for saving levels.
var level_array: Array[String] = ["lvl_1", "lvl_2", "lvl_3", "lvl_4", "lvl_5", "lvl_6"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Global.checkpoint)
	if Global.checkpoint != Vector2(0,0):
		global_position = Global.checkpoint
	if plinko_pad:
		plinko_pad.connect("plinko_lost", die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# !!!!! Circcle here, I commented out the allow_jump bool and just made it so that
	# when the player inputs a jump, the raycast is forced an update and it checks
	# if u can jump, you could double jump still because as you left the ground
	# the raycast re-enabled allow_jump, hopefully this is how u intended it!
	
	if ray_cast_2d.is_colliding(): #check if player is on the floor
		#allow_jump = true
		
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
	
	if Input.is_action_just_pressed("jump"): #checks if conditions are right to jump
		ray_cast_2d.force_raycast_update()
		if ray_cast_2d.is_colliding():
			#allow_jump = false #stop double jumping
			jump.play()
			linear_velocity.y = jump_force #apply jump force
	# if player presses E and has_dynamite is set to true, the dynamite scene is loaded in
	# and instanced, then the position is set to be above the player & the velocity is matched
	# after which the dynamite is actually added into the scene
	
	if Input.is_action_just_pressed("use") and has_dynamite:
		has_dynamite = false
		var dynamite = load("res://scenes/dynamite.tscn")
		var instance: RigidBody2D = dynamite.instantiate()
		get_tree().current_scene.add_child(instance)
		instance.linear_velocity = linear_velocity
		instance.global_position = Vector2(global_position.x, global_position.y - 150)
		instance.explode()
 
	if dead:
		rotation = 0
		freeze = true
		lock_rotation = true


func _on_hitbox_spikes_area_entered(area: Area2D) -> void:
	if area.name == "spikes":
		die()
	
	if area.name == "goal":
		var config = ConfigFile.new()
		var err: Error = config.load("user://levels.cfg")
		if err != OK:
			return
		config.set_value("LEVELS", level_array[Global.level], true)
		config.save("user://levels.cfg")
		print(config.get_value("LEVELS", level_array[Global.level]))
		Global.level += 1
		Global.checkpoint = Vector2(0, 0)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/victory_screen.tscn")
	

func _on_body_entered(_body: Node) -> void: #when colliding with the ground
	bounce.pitch_scale = randf_range(0.8,1.1)
	bounce.volume_linear = abs(linear_velocity.x + linear_velocity.y) / 1000 + 0.01
	bounce.play()

func die():
	if dead: return
	
	dead = true
	$Explosion.play()
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	if is_inside_tree() and get_tree() != null:
		get_tree().reload_current_scene()

#connected to pickup_area when another area enters it
func pickup_item(area: Area2D) -> void:
	if area.name == "dynamite_pickup":
		if area.get_parent().can_pickup:
			print("boom!")
			has_dynamite = true
			area.get_parent().queue_free()
