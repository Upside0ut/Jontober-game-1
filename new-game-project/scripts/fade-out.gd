extends ColorRect

var fade_out := false
signal go_to_credits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_out:
		modulate.a += delta
	
	if modulate.a >= 1.0:
		go_to_credits.emit()
