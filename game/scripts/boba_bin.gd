extends Button

@onready var boba_layer_1: Sprite2D = $"../Node2D/Boba-layer1"
@onready var boba_layer_2: Sprite2D = $"../Node2D/Boba-layer2"
@onready var boba_layer_3: Sprite2D = $"../Node2D/Boba-layer3"
@onready var boba_layer_4: Sprite2D = $"../Node2D/Boba-layer4"
@onready var boba_layer_5: Sprite2D = $"../Node2D/Boba-layer5"

var boba_layers: Array[Sprite2D]
var current_index := 0

func _ready() -> void:
	boba_layers = [
		boba_layer_1,
		boba_layer_2,
		boba_layer_3,
		boba_layer_4,
		boba_layer_5
	]
	for layer in boba_layers:
		layer.visible = false
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if current_index < boba_layers.size():
		boba_layers[current_index].visible = true
		current_index += 1
