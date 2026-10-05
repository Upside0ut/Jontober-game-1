extends Node2D

@onready var player: Node2D = get_node("player_2_normal")
var adjust_position = true
var rolling = false
var dyamite_count = 0
var can_roll = true
var ceiling = false
#list of mannequins in which the player is in the distortion area
var mannequin_array: Array[Area2D]
var distortion_amount: float = 0.0
var fov_multiplier: float = 1.0
var shrunken = false

var dying = false
var can_move = true
var saved_from_death = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$effects/VideoStreamPlayer.modulate.a = lerp($effects/VideoStreamPlayer.modulate.a, distortion_amount, .12)
	if adjust_position:
		$position.position = player.position
	if Input.is_action_just_pressed("roll"):
		if can_roll and !ceiling and !shrunken and can_move:
			roll()
		else:
			pass
	
	if rolling and !can_roll:
		roll()
#	dynamite
	if Input.is_action_just_pressed("use") and dyamite_count > 0 and adjust_position and can_move:
		dyamite_count -= 1
		var dynamite = load("res://scenes/dynamite.tscn")
		var instance: RigidBody2D = dynamite.instantiate()
		get_tree().current_scene.add_child(instance)
		if player is RigidBody2D:
			instance.linear_velocity = player.linear_velocity
		else:
			instance.linear_velocity = player.velocity
		instance.global_position = Vector2($position.global_position.x, $position.global_position.y - 150)
		instance.explode()
	
	camera()

func camera():
	$position/Camera2D.zoom = Vector2(0.75 * fov_multiplier, 0.75 * fov_multiplier)

func roll():
	adjust_position = false
	var collision: CollisionShape2D
	if has_node("player_2_normal"):
		player = get_node("player_2_normal")
	elif has_node("player_2_rolling"):
		player = get_node("player_2_rolling")
	collision = player.get_node("CollisionShape2D")
	print(player)
	print(rolling)
	if !rolling:
		rolling = true
		player.visible = false
		collision.disabled = true
		var scene = load("res://scenes/player_2_rolling.tscn")
		var instance: RigidBody2D = scene.instantiate()
		instance.linear_velocity = player.velocity
		instance.position = $position.position
		player.queue_free()
		player = instance
		instance.visible = false
		add_child(instance)
		instance.visible = true
	else:
		rolling = false
		player.visible = false
		collision.set_deferred("disabled", true)
		var scene = load("res://scenes/player_2_normal.tscn")
		var instance: CharacterBody2D = scene.instantiate()
		instance.velocity = player.linear_velocity
		instance.position = $position.position
		player.queue_free()
		player = instance
		instance.visible = false
		call_deferred("add_child", instance)
		instance.visible = true

	print(player)
	adjust_position = true

func shrink(boolean: bool):
	if boolean and !shrunken:
		if rolling:
			roll()
		player.scale = Vector2(player.scale.x / 5, player.scale.y / 5)
		$position.scale = Vector2($position.scale.x / 5, $position.scale.y / 5)
		fov_multiplier += 1.5
		shrunken = true
	elif shrunken:
		player.scale = Vector2(player.scale.x * 5, player.scale.y * 5)
		$position.scale = Vector2($position.scale.x * 5, $position.scale.y * 5)
		fov_multiplier -= 1.5
		shrunken = false

func _on_interact_area_entered(area: Area2D) -> void:
	if area.name == "dynamite_pickup":
		if area.get_parent().can_pickup:
			dyamite_count += 1
			area.get_parent().queue_free()
	if area.name == "distortion_area":
		can_roll = false
		mannequin_array.append(area)
		distortion_amount += .1
		
	if area.name == "zoom_area":
		fov_multiplier -= area.zoom_scale
	if area.name == "shrink_area":
		shrink(true)
		print("shrink1")
		area.name = "used"
		area.get_parent().consume()
		
	if area.name == "death_area" and !dying:
		death(area.get_parent().name)

func _on_interact_area_exited(area: Area2D) -> void:
	if area.name == "zoom_area":
		fov_multiplier -= area.zoom_scale
	if area.name == "distortion_area":
		mannequin_array.erase(area)
		if mannequin_array.size() == 0:
			can_roll = true
		distortion_amount -= .1

	if area.name == "zoom_area":
		fov_multiplier += area.zoom_scale
	

func _on_interact_body_entered(body: Node2D) -> void:
	if body.name.contains("security"):
		if shrunken:
			death("security")


func sounds(type: String):
	if type == "jump":
		$position/sounds/jump.play()

func death(cause: String):
	dying = true
	var timer_time: float = 0.0
	if cause.contains("mannequin"):
		$position/GPUParticles2D.emitting = true
		timer_time = 1.5
	if cause.contains("security"):
		timer_time = 2.5
		can_move = false
	await get_tree().create_timer(timer_time).timeout
	if !saved_from_death:
		$AnimationPlayer.play("die")
		player.visible = false
		can_move = false
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
