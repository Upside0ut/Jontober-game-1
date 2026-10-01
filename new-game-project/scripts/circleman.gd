extends AnimatedSprite2D


func interact(Area: Area2D):
	$speech.visible = true
	$speech.play("default")
