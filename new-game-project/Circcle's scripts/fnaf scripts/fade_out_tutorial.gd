extends Node2D

@export var fade_out_nodes : Array[Node] = []
var fade_out := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	for node in fade_out_nodes:
		node.visible = false
	
	if NightData.current_night == 0 and !NightData.custom_night:
		visible = true
		
		await get_tree().create_timer(10.0).timeout
		var tween := create_tween().set_parallel(true)
		for node in fade_out_nodes:
			tween.tween_property(node, "modulate:a", 0.0, 3.0)
