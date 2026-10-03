extends Sprite2D

@export var follows = true
@export var sprites_a: Array[Texture]
@export var sprites_b: Array[Texture]
@export var sounds: Array[AudioStream]
@export var arms: bool
var rng = RandomNumberGenerator.new()
var target: Node2D

func _ready() -> void:
	target = get_tree().current_scene.get_node("player_2")
	$sound.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
	$sound.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if arms:
		texture = sprites_a[rng.randi_range(0, sprites_a.size() - 1)]
	else:
		texture = sprites_b[rng.randi_range(0, sprites_b.size() - 1)]
	if follows:
		$GPUParticles2D.emitting = true
		visible = false
		global_position = target.get_node("position").global_position
		await get_tree().create_timer(1.0).timeout
		visible = true
		if $floor.is_colliding():
			global_position = $floor.get_collision_point()
			global_position.y -= 128
