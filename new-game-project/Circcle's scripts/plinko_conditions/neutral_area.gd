class_name Neutral_Area
extends Area2D

signal changed_state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Plinko_Player:
		changed_state.emit()
