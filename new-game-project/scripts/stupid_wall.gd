extends Node2D

var being_destroyed = false

func _ready() -> void:
	if Global.destroyed_wall == true:
		destroy()

func _on_destruct_area_area_entered(area: Area2D) -> void:
	if area.name == "explosion_area":
		$crumble.play()
		if !being_destroyed:
			destroy()
			being_destroyed = true

func destroy():
	Global.destroyed_wall = true
	$GPUParticles2D.emitting = true
	$timer.start()


func _on_timer_timeout() -> void:
	$wall.queue_free()
	$Sprite2D.visible = false
