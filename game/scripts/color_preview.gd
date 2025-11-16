extends ColorRect

@onready var color_rect: ColorRect = $"."

@onready var blue: HSlider = $"../Blue-bottle/HSlider"
@onready var green: HSlider = $"../Green-bottle/HSlider2"
@onready var red = $"../Red-bottle/HSlider3"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(0.3).timeout	
	_set_rect_color()

func _map_slider_to_light_color(value: float) -> float:
	return lerp(180.0, 255.0, value / 100.0) / 255.0

func _set_rect_color() -> void:
	var r = _map_slider_to_light_color(red.value)
	var g = _map_slider_to_light_color(green.value)
	var b = _map_slider_to_light_color(blue.value)
	self.color = Color(r, g, b)
	print("Color set to:", self.color)
