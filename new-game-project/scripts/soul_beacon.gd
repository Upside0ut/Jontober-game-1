extends Node2D

var mannequins: Array[Node2D]
var active = false

func activate():
	if !active:
		active = true
		$GPUParticles2D.visible = true
		$GPUParticles2D2.visible = true
		$AnimatedSprite2D.play("active")
		$AudioStreamPlayer2D.play()
		$loop.play()
		$loop2.play()
		$Icon.visible = true
		$beacon_area/CollisionShape2D.disabled = true
		for n in mannequins:
			n.death()


func _on_activate_area_body_entered(body: Node2D) -> void:
	if body.name.contains("player"):
		activate()


func _on_beacon_area_area_entered(area: Area2D) -> void:
	if area.get_parent().name.contains("mannequin"):
		mannequins.append(area.get_parent())
