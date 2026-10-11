extends Sprite2D

@export var root_node : Node2D
@onready var lights : Node2D = $lights
@onready var alarm_noise = $"alarm_noise (VOLUME IN CODE)"
@onready var ambient_lights := [$dim_alarm_ambient,$dim_alarm_ambient2]
@onready var glass_break_sfx = $glass_break_sfx
@onready var spark_sfx = $spark_sfx

@export var Randy : Node2D
@export var uh_oh : RichTextLabel
@onready var imminent_death = $alarm_break_run

@export var rotation_speed : float = 360.0
#change to textureprogressbar later
@export var rage_bar : ProgressBar
var rage_locked := false

var death_imminent_sfx_played := false

const MAX_RAGE_TIME := 45.0
var current_rage := 0.0 # in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	uh_oh.visible = false
	rage_bar.value_changed.connect(_on_value_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if root_node.alarm_turned_on and !rage_locked:
		lights.visible = true
		if !alarm_noise.playing:
			alarm_noise.volume_linear = 0.4
			alarm_noise.play()
		#modulate.r = 1.0
		
		lights.rotation_degrees += delta*rotation_speed
		rage_bar.value += delta*20.0
	else:
		lights.visible = false
		lights.rotation_degrees = 0
		if alarm_noise.playing:
			alarm_noise.volume_linear = clamp(alarm_noise.volume_linear-delta*4.0,0.01,1.0)
			if alarm_noise.volume_linear <= 0.2:
				alarm_noise.stop()
		## 50 is the original color of the alarm, im lazy so im hardcoding
		#modulate.r = 50.0 / 255.0
		
		if !rage_locked:
			rage_bar.value -= delta*2.0
		else:
			if !imminent_death.playing and !death_imminent_sfx_played:
				imminent_death.play()
				death_imminent_sfx_played = true
			if uh_oh.visible:
				uh_oh.modulate.a -= delta/2.0
			imminent_death.pitch_scale += delta/5.0

func _on_value_changed(value):
	if value >= 100:
		rage_locked = true
		glass_break_sfx.play()
		spark_sfx.play()
		for light in ambient_lights:
			light.visible = false
		
		uh_oh.visible = true
		print("uh oh!")
		#something wicked this way comes or wtv ultrakill

func _on_alarm_break_run_finished() -> void:
	print("...")
	await get_tree().create_timer(randf_range(1.5,5.0)).timeout
	Randy.jumpscare.emit("Randy")
