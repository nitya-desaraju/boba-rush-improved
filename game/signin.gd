extends Node

var username

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_on_enter_pressed.call()


@onready var input_box = $UserInputBox

func _on_enter_pressed() -> void:
	var input = input_box.text
	username = input
	var next_scene = preload("res://scenes/main.tscn")
	print("switching to main")
	get_tree().change_scene_to_packed(next_scene)
