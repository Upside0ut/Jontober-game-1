extends AnimatedSprite2D

var opened = false

func open(body: Node2D):
	if body is RigidBody2D and !opened:
		opened = true
		play("default")
		$open.play()
