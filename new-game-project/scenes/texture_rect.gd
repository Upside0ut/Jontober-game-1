extends TextureRect

@onready var atlas := texture as AtlasTexture

var t := 0.0
var second := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if t >= 0.1:
		t = 0.0
		second = !second
		atlas.region.position.x = 1920 if second else 0
