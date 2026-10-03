extends Area2D

@export var zoom_scale: float = 1.0
#var reset
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.name == "player_2_rolling" or body.name == "player_2_normal":
		#reset = body.get_parent().get_node("position/Camera2D").zoom
		#body.get_parent().get_node("position/Camera2D").zoom = Vector2(zoom_scale, zoom_scale)
		#
#
#
#func _on_body_exited(body: Node2D) -> void:
	#if body.name == "player_2_rolling" or body.name == "player_2_normal":
		#body.get_parent().get_node("position/Camera2D").zoom = reset
