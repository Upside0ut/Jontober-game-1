extends AnimatedSprite2D


func interact(Area: Area2D):
	if !$speak.playing:
		$speech.visible = true
		$speech.play("default")
		$speak.play()
