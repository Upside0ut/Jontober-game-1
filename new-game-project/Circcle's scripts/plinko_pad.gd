extends CanvasLayer

@export var plinko_subviewport : SubViewport

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
