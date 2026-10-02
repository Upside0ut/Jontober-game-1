extends Node2D

@onready var player: Node2D = get_node("player_2_normal")
var adjust_position = true
var rolling = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if adjust_position:
		$position.global_position = player.global_position
	if Input.is_action_just_pressed("roll"):
		roll()

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
		instance.global_position = $position.global_position
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
		instance.global_position = $position.global_position
		player.queue_free()
		player = instance
		instance.visible = false
		add_child(instance)
		instance.visible = true

	print(player)
	adjust_position = true
