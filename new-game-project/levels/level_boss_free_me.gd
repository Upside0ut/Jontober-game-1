extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("HELP_H") and
		Input.is_action_pressed("HELP_E") and
		Input.is_action_pressed("HELP_L") and
		Input.is_action_pressed("HELP_P") and
		get_node_or_null("BossAbstraction") != null):
			if $BossAbstraction.health > 30:
				$BossAbstraction.health = 30
