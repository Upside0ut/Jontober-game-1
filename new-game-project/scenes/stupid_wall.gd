extends Node2D



func _on_destruct_area_area_entered(area: Area2D) -> void:
	if area.name == "explosion_area":
		destroy()

func destroy():
	$crumble.play()
	$wall/CollisionShape2D.queue_free()
	visible = false
