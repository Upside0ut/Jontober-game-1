extends Node2D



func _on_destruct_area_area_entered(area: Area2D) -> void:
	if area.name == "explosion_area":
		$Sprite2D.visible = false
		$GPUParticles2D.emitting = true
