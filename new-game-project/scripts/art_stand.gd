extends Node2D

@export var art_name: String = "Testing 123"

func _ready() -> void:
	$Label.text = art_name

func _on_texture_rect_mouse_entered() -> void:
	$Label.visible = true


func _on_texture_rect_mouse_exited() -> void:
	$Label.visible = false
