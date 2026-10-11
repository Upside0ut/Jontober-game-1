extends PointLight2D

#change to textureprogressbar later maybe?
@export var flashlight_bar : ProgressBar
@export var flashlight_click_sfx : AudioStreamPlayer

const MAX_FLASHLIGHT_TIME := 45.0
var flash_left := MAX_FLASHLIGHT_TIME # in seconds
var can_flash := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	flashlight_bar.value = remap(flash_left,MAX_FLASHLIGHT_TIME,0,100,0)
	#print(flashlight_bar.value)
	
	if Input.is_action_pressed("use_flashlight") and flash_left > 0.0 and can_flash:
		
		if !visible:
			flashlight_click_sfx.pitch_scale = randf_range(.9, 1.1)
			flashlight_click_sfx.play()
		
		visible = true
		flash_left -= delta
		
	else:
		visible = false
	global_position = get_global_mouse_position()
