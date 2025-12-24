extends Control

@onready var name_input = $name
@onready var create_button = $createButton
@onready var join_button = $joinButton

var hovered = Color(0.8, 0.8, 0.8, 1.0)
var normal = Color(1.0, 1.0, 1.0, 1.0)

var player_name : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_button(create_button)
	setup_button(join_button)

	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)

func setup_button(btn: TextureButton):
	btn.self_modulate = normal
	btn.mouse_entered.connect(func(): _fade_color(btn, hovered))
	btn.mouse_exited.connect(func(): _fade_color(btn, normal))

func _fade_color(btn: TextureButton, target_color: Color):
	var tween = create_tween()
	tween.tween_property(btn, "self_modulate", target_color, 0.1)

func _on_create_pressed():
	save_name()
	GameManager.player_name = name_input.text
	GameManager.is_host = true
	get_tree().change_scene_to_file("res://scenes/create_room.tscn")

func _on_join_pressed():
	save_name()
	GameManager.player_name = name_input.text
	GameManager.is_host = false
	get_tree().change_scene_to_file("res://scenes/join_room.tscn")

func save_name():
	player_name = name_input.text.strip_edges()
	var config = ConfigFile.new()
	config.set_value("Player", "name", player_name)
	config.save("user://save_game.cfg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
