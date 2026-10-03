extends Node2D

@export var alarm_pauses_attack := true

@export var alarm_light : Node2D
@export var alarm_rope : Node2D
@export var fnaf_pad : CanvasLayer

@export var rage_bar : ProgressBar
@export var pad_opener : Control

@export var Agnese : Node2D

var pad_open := false
var alarm_turned_on := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pad_opener.mouse_entered.connect(_on_pad_opener)
	fnaf_pad.plinko_won.connect(_on_plinko_won)
	fnaf_pad.plinko_lost.connect(_on_plinko_lost)
	alarm_rope.alarm_on.connect(_alarm_on)
	alarm_rope.alarm_off.connect(_alarm_off)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_jumpscare():
	pass

func _on_plinko_won():
	if !alarm_light.rage_locked:
		rage_bar.value -= 20
func _on_plinko_lost():
	if !alarm_light.rage_locked:
		rage_bar.value += 5

func _alarm_on():
	print("ALARM ON")
	alarm_turned_on = true

func _alarm_off():
	print("ALARM OFF")
	alarm_turned_on = false

func _on_pad_opener():
	if fnaf_pad.is_moving: return
	if pad_open:
		fnaf_pad.leave_view()
		print("in")
		pad_open = false
	else:
		print("out")
		fnaf_pad.enter_view()
		pad_open = true
