extends AnimatedSprite2D


func interact(Area: Area2D):
	if !$speak.playing:
		$speech.visible = true
		$speech.play("default")
		$speak.play()
	if Area.name == "explosion_area":
		death()


func death():
	queue_free()
