extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.name == "hitbox (spikes)":
		get_parent().get_node("Player").die()
		await wait(0.1)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/pre_boss.tscn")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
