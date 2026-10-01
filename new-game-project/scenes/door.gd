extends AnimatedSprite2D

var opened = false

func open(body: Node2D):
	if body is RigidBody2D:
		$Area2D/CollisionShape2D.disabled = true
		play("default")
		$open.play()
