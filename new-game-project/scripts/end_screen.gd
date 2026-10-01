extends Control

@export var end_animation : AnimatedSprite2D
@export var fading_rect : ColorRect

func _ready() -> void:
	fading_rect.connect("go_to_credits", _on_go_to_credits)

func _on_animated_sprite_2d_animation_finished() -> void:
	print("asd")
	fading_rect.fade_out = true

func _on_go_to_credits():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/credits.tscn")
