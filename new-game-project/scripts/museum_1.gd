extends Node2D




func _on_music_start_body_entered(body: Node2D) -> void:
	if (body is CharacterBody2D or body is RigidBody2D) and !$song.playing:
		$song.play()




func _on_next_level_body_entered(body: Node2D) -> void:
	if body.name.contains("player"):
		get_tree().call_deferred("change_scene_to_file", "res://levels/security_level.tscn")
