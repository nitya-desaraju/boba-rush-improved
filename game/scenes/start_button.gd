extends TextureButton

var hovered = Color(0.8,0.8,0.8,1)
var normal = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Button size is: ", size)
	self.self_modulate = normal

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)


func _on_mouse_entered():
	print("mouse hovering")
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", hovered, 0.1)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", normal, 0.1)

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/signin.tscn")

func _process(_delta):
	if is_hovered():
		print("The engine says I am hovered!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass
