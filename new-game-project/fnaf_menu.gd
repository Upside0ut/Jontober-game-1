extends Control

@export var nights : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nights.text != "Night %s" % str(NightData.current_night+1):
		nights.text =  "Night %s" % str(NightData.current_night+1)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/fnaf_level.tscn")
