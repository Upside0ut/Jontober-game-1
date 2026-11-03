extends AnimatedSprite2D

var opened = false

signal just_opened

func open(body: Node2D):
	if (body is RigidBody2D or body is CharacterBody2D) and !opened:
		opened = true
		just_opened.emit()
		play("default")
		$open.play()
