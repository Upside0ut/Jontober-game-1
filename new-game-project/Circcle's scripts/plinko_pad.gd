extends CanvasLayer

@export var plinko_subviewport : SubViewport
@export var plinko_Sprite2D : Sprite2D
@export var plinko_prison : Node2D
@export var prison_delete : AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child = plinko_subviewport.get_child(0)
	child.connect("game_lost", _on_game_lost)
	child.connect("game_won", _on_game_won)

signal plinko_lost
func _on_game_lost():
	plinko_lost.emit()

signal plinko_won
func _on_game_won():
	plinko_won.emit()
	plinko_prison.queue_free()
	prison_delete.play()
	await get_tree().create_timer(1.5).timeout
	leave_view()

func leave_view():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(plinko_Sprite2D, "global_position:x", plinko_Sprite2D.global_position.x-1000, 1.0)
