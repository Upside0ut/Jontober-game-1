extends Control

@onready var star_one = $Star1.get_child(0)
@onready var star_two = $Star2.get_child(0)
@onready var star_three = $Star3.get_child(0)

@onready var bronze_button = $Bronze
@onready var silver_button = $Silver
@onready var gold_button = $Gold

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	bronze_button.modulate = Color("#ffffff")
	silver_button.modulate = Color("#ffffff")
	gold_button.modulate = Color("#ffffff")
	
	if NightData.beaten_bronze_mode:
		star_one.modulate.a = 1.0 
	if NightData.beaten_silver_mode:
		star_two.modulate.a = 1.0 
	if NightData.beaten_gold_mode:
		star_three.modulate.a = 1.0 
	
	bronze_button.modulate = Color("#ffab4a") if NightData.bronze_active else Color.WHITE
	silver_button.modulate = Color("#91caff") if NightData.silver_active else Color.WHITE
	gold_button.modulate = Color("#ffea4d") if NightData.gold_active else Color.WHITE
