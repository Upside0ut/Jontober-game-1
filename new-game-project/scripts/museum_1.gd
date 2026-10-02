extends Node2D




func _on_music_start_body_entered(body: Node2D) -> void:
	if (body is CharacterBody2D or body is RigidBody2D) and !$song.playing:
		$song.play()
