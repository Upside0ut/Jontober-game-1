extends Viewport

var plinko_scene_path := "res://scenes/level_02_circcle_plinko.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var plinko_scene : PackedScene = load(plinko_scene_path)
	add_child(plinko_scene.instantiate(), true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
