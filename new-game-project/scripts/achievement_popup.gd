class_name Achievements
extends Control

## time to read the text
@export var achievement_time := 5.0
@onready var decreased_ach_time := achievement_time

@export var achievement_texture : TextureRect
@export var v_separator : VSeparator
@export var achievement_text : RichTextLabel

var processing_ach_queue := false

var tween : Tween
var origin_pos := Vector2.ZERO
var oob_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Global.achievement_changed.connect(_on_achievement)
	
	origin_pos = position
	oob_pos = position - get_viewport_rect().size
	position.x = oob_pos.x

func _on_achievement():
	if processing_ach_queue: return
	processing_ach_queue = true
	
	while not Global.achievement_queue.is_empty():
		var popped_achievement = Global.achievement_queue.pop_front()
		match popped_achievement:
			"boss_beaten" :
				achievement_texture.texture = load("res://Skins/randy_boss.png")
				achievement_text.text = "You unlocked Boss! (Skin)"
			_:
				achievement_texture.texture = PlaceholderTexture2D.new()
				achievement_text.text = "Unrecognized achievement (not set): %s" % popped_achievement
		decreased_ach_time = clampf(decreased_ach_time-len(Global.achievement_queue)*0.3, 1.0, achievement_time)
		await _show_achievement_anim()
	decreased_ach_time = achievement_time
	processing_ach_queue = false

func _show_achievement_anim():
	if tween != null and tween.is_running(): await tween.finished
	
	tween = enter_view()
	
	await tween.finished
	await get_tree().create_timer(decreased_ach_time).timeout
	
	tween = exit_view()
	
	await tween.finished

func enter_view():
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", origin_pos.x, 0.5)
	return tween

func exit_view():
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:x", oob_pos.x, 0.5)
	return tween
