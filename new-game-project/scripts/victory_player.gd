extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.current_skin_png:
		texture = Global.current_skin_png
