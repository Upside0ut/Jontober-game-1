extends Control

@export var end_animation : AnimatedSprite2D
@export var fading_rect : ColorRect

func _ready() -> void:
	fading_rect.connect("go_to_next_chapter", _on_go_to_next_chapter)
	await get_tree().create_timer(5.0).timeout
	$AnimationPlayer.play("question_mark")

func _on_animated_sprite_2d_animation_finished() -> void:
	print("asd")
	fading_rect.fade_out = true

func _on_go_to_next_chapter():
	Global.level = 0
	get_tree().call_deferred("change_scene_to_file", "res://levels/museum_1.tscn")
