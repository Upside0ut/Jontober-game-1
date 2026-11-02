extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == get_parent().get_node("Player"):
		Global.change_to_museum_fancy()
