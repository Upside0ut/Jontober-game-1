extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_dash_point_body_entered(body: Node2D) -> void:
	if(body != get_parent().get_node("BossAbstraction")):
		return
	
	get_parent().get_node("BossAbstraction").reached_dash_point()
