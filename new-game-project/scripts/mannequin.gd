extends Sprite2D

@export var changes = true
@export var sprites: Array[Texture]
var rng = RandomNumberGenerator.new()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	texture = sprites[rng.randi_range(0, sprites.size() - 1)]
