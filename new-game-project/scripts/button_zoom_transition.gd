extends Camera2D

@export var zoom_signaling_node : Node
@export var fader : Node
@export var song : Node
@export var fade_time := 0.8
var clicked_play := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if zoom_signaling_node:
		zoom_signaling_node.connect("zoomed", _on_zoom_to_button)
	else:
		printerr("Zoom signaling node not set!")

func _on_zoom_to_button(path,button_center):
	var zoom_to_use := 2.0
	
	# the reason this is needed is because the camera's anchor mode is set
	# to Fixed Top Left because its under UI which is kinda wonky but wtv
	var zoom_calc = button_center - get_viewport_rect().size / (2.0  * zoom_to_use)
	
	zoom_to_target(zoom_to_use,zoom_calc)
	fade_then_change(path)

func zoom_to_target(zoom_to_use,zoom_calc):
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self,"zoom",Vector2.ONE * zoom_to_use,fade_time)
	tween.tween_property(self,"global_position",zoom_calc,fade_time)

func fade_then_change(scene_path : String) -> void:
	if clicked_play: return
	clicked_play = true
	
	fader.fade_out_by_default = false
	fader.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, fade_time)
	tween.tween_property(song, "volume_linear", 0.0, fade_time)
	await tween.finished
	
	get_tree().change_scene_to_file(scene_path)
