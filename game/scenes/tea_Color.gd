extends ColorRect

@onready var blue: HSlider = $"../Blue-bottle/HSlider"
@onready var green: HSlider = $"../Green-bottle/HSlider2"
@onready var red = $"../Red-bottle/HSlider3"

@onready var button: Button = $"../ColorRect/Button"


@onready var color_rect_main: ColorRect = $"."
@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var color_rect_3: ColorRect = $ColorRect3
@onready var color_rect_4: ColorRect = $ColorRect4
@onready var color_rect_5: ColorRect = $ColorRect5
@onready var color_rect_6: ColorRect = $ColorRect6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for rect in [
		color_rect_main, color_rect, color_rect_2, color_rect_3,
		color_rect_4, color_rect_5, color_rect_6
	]:
		rect.visible = false
	button.pressed.connect(_on_button_pressed)



func _map_slider_to_light_color(value: float) -> float:
	return lerp(180.0, 255.0, value / 100.0) / 255.0
	
func _set_rect_color(rect) -> void:
	var r = _map_slider_to_light_color(red.value)
	var g = _map_slider_to_light_color(green.value)
	var b = _map_slider_to_light_color(blue.value)
	rect.color = Color(r, g, b)

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	var rects = [
		color_rect_6, color_rect_5, color_rect_4,
		color_rect_3, color_rect_2, color_rect, color_rect_main
	]
	for rect in rects:
		rect.visible = true
		_set_rect_color(rect)
		await get_tree().create_timer(0.1).timeout	
