extends Area2D

signal boss_entered_signal

func _on_center_point_body_entered(body: Node2D) -> void:
	if(body == get_parent().get_node("BossAbstraction")):
		emit_signal("boss_entered_signal")
