extends Node2D


func _on_nextlevel_body_entered(body: Node2D) -> void:
	if body.name.contains("player"):
		get_tree().change_scene_to_file("res://levels/room_1.tscn")
