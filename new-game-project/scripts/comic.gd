extends Control

@export var timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and timer.time_left > 0.1:
		timer.stop()
		timer.timeout.emit()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://levels/level_01.tscn")
