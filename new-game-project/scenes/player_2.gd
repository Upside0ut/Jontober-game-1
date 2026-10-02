extends Node2D

@onready var player: Node2D = get_node("player_2_normal")
var adjust_position = true
var rolling = false
var dyamite_count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if adjust_position:
		$position.position = player.position
	if Input.is_action_just_pressed("roll"):
		roll()
		
#	dynamite
	if Input.is_action_just_pressed("use") and dyamite_count > 0 and adjust_position:
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
		collision.disabled = true
		var scene = load("res://scenes/player_2_normal.tscn")
		var instance: CharacterBody2D = scene.instantiate()
		instance.velocity = player.linear_velocity
		instance.position = $position.position
		player.queue_free()
		player = instance
		instance.visible = false
		add_child(instance)
		instance.visible = true

	print(player)
	adjust_position = true

func _on_interact_area_entered(area: Area2D) -> void:
	if area.name == "dynamite_pickup":
		if area.get_parent().can_pickup:
			dyamite_count += 1
			area.get_parent().queue_free()
