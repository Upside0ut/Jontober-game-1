extends Sprite2D

@export var changes = true
@export var sprites: Array[Texture]
var rng = RandomNumberGenerator.new()
var target: Node2D

func _ready() -> void:
	target = get_tree().current_scene.get_node("player_2")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	texture = sprites[rng.randi_range(0, sprites.size() - 1)]
	$GPUParticles2D.emitting = true
	visible = false
	global_position = target.get_node("position").global_position
	await get_tree().create_timer(1.0).timeout
	visible = true
	if $floor.is_colliding():
		global_position = $floor.get_collision_point()
		global_position.y -= 128
