extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not OS.is_debug_build():
		visible = false
		disabled = true
		queue_free()

func _on_pressed() -> void:
	if OS.is_debug_build():
		Global.clear_progress()
