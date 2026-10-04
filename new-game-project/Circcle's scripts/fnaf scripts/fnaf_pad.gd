extends CanvasLayer

@export var plinko_subviewport : SubViewport
@export var plinko_Sprite2D : Sprite2D
@export var flashlight : PointLight2D

var is_moving := false
var tween : Tween
var plinko_root
var pad_move_amount := 400.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plinko_Sprite2D.global_position.x += pad_move_amount
	plinko_root = plinko_subviewport.get_child(0)
	plinko_root.connect("game_lost", _on_game_lost)
	plinko_root.connect("game_won", _on_game_won)

signal plinko_lost
func _on_game_lost():
	plinko_lost.emit()

signal plinko_won
func _on_game_won():
	plinko_won.emit()
	#await get_tree().create_timer(1.5).timeout
	#leave_view()

func leave_view():
	if is_moving: return
	is_moving = true
	plinko_root.process_mode = Node.PROCESS_MODE_DISABLED
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(plinko_Sprite2D, "global_position:x", plinko_Sprite2D.global_position.x+pad_move_amount, 0.3)
	await tween.finished
	
	if flashlight: flashlight.can_flash = true
	is_moving = false
	#plinko_subviewport.get_tree().paused = true

func enter_view():
	if is_moving: return
	if flashlight: flashlight.can_flash = false
	is_moving = true
	plinko_root.process_mode = Node.PROCESS_MODE_INHERIT 
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(plinko_Sprite2D, "global_position:x", plinko_Sprite2D.global_position.x-pad_move_amount, 0.3)
	await tween.finished
	
	is_moving = false
	#get_tree().paused = false
