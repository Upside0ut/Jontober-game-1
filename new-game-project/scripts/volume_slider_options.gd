extends HSlider

@export var resize_size : int = 64

var normal_grabber: Texture2D
var hover_grabber: Texture2D
var drag_grabber: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var normal_image := resize_img(get_theme_icon("grabber", "HSlider").get_image(),resize_size)
	var hover_image := resize_img(get_theme_icon("grabber_highlight", "HSlider").get_image(),resize_size)
	var drag_image := resize_img(get_theme_icon("grabber_disabled", "HSlider").get_image(),resize_size)
	
	normal_grabber = normal_image
	hover_grabber = hover_image
	drag_grabber = drag_image
	
	add_theme_icon_override("grabber", normal_grabber)
	add_theme_icon_override("grabber_disabled", normal_grabber)
	add_theme_icon_override("grabber_highlight", hover_grabber)
	

func resize_img(image : Image, resize_to : int) -> ImageTexture:
	image.resize(resize_to, resize_to, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

func _on_drag_started() -> void:
	add_theme_icon_override("grabber_highlight", drag_grabber)

func _on_drag_ended(_value_changed: bool) -> void:
	add_theme_icon_override("grabber_highlight", hover_grabber)
