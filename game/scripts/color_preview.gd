extends ColorRect

@onready var blue: HSlider = $"../Blue-bottle/HSlider"
@onready var green: HSlider = $"../Green-bottle/HSlider2"
@onready var red = $"../Red-bottle/HSlider3"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_rect_color() -> void:
	var r = red.value / 255.0
	var g = green.value / 255.0
	var b = blue.value / 255.0
	self.color = Color(r, g, b)
	#rect.color = Color(red, green, blue)
