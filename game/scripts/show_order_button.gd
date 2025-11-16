extends Button

@onready var order_sign: Sprite2D = $"../Order-sign"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	order_sign.visible = !order_sign.visible
