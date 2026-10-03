extends Node2D

@export var Agnese : Node2D
@export var Agnese_jumpscare : Sprite2D
@export var Randy : Node2D
@export var Randy_jumpscare : Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Agnese.jumpscare.connect(_on_jumpscare)
	Randy.jumpscare.connect(_on_jumpscare)

func _on_jumpscare(enemy):
	match enemy:
		"Agnese":
			if Randy_jumpscare.visible == true:
				Randy_jumpscare.visible = false
			Agnese_jumpscare.visible = true
		"Randy":
			Randy_jumpscare.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
