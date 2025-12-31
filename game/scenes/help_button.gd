extends TextureButton 

var hovered = Color(0.8, 0.8, 0.8, 1.0)
var normal = Color(1.0, 1.0, 1.0, 1.0)

@onready var popup = $"../helpPopup"
@onready var overlay = $"../overlay"
@onready var start_button = $"../startButton"
@onready var close_button = $"../helpPopup/closeButton"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.self_modulate = normal
		
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pressed.connect(_on_open_help)
	close_button.pressed.connect(_on_close_help)
	
	close_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(close_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	close_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(close_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", hovered, 0.1)
	
func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", normal, 0.1)
	
func _on_open_help():
	overlay.show()
	popup.show()
	start_button.disabled = true
	self.self_modulate = normal 

func _on_close_help():
	overlay.hide()
	popup.hide()
	start_button.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
