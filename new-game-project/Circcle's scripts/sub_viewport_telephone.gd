extends Viewport

var plinko_scene_path := "res://scenes/level_02_circcle_plinko.tscn"
@export var fnaf_ver := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var plinko_scene : PackedScene = load(plinko_scene_path)
	var instantiated_plinko = plinko_scene.instantiate()
	if fnaf_ver:
		instantiated_plinko.fnaf_ver = true
	add_child(instantiated_plinko, true)
