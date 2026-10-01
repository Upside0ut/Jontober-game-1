extends RigidBody2D

signal explosion()
var exploding = false
var can_explode = true
@export var can_pickup = false

func explode():
	if can_explode:
		can_explode = false
		exploding = true
		$anim.play("lit")

func _on_anim_animation_finished() -> void:
	if exploding:
		freeze = true
		$collision.disabled = true
		exploding = false
		explosion.emit()
		$booom.emitting = true
		await get_tree().create_timer(0.2).timeout
		$anim.visible = false
		$explosion_area/CollisionShape2D.disabled = false
		await get_tree().create_timer(2.2).timeout
		$explosion_area/CollisionShape2D.disabled = true
