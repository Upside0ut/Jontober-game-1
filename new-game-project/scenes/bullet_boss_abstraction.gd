extends CharacterBody2D

var rng = RandomNumberGenerator.new()
var move_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("TextureRectBlue").hide()
	get_node("TextureRectRed").hide()
	get_node("TextureRectYellow").hide()
	
	match rng.randi_range(0, 2):
		0:
			get_node("TextureRectBlue").show()
		1:
			get_node("TextureRectRed").show()
		2:
			get_node("TextureRectYellow").show()

func _physics_process(delta: float) -> void:
	move_and_slide()

func shoot(direction: Vector2):
	velocity = direction * move_speed
