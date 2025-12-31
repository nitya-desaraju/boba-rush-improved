extends Control

@onready var code_input = $codeInput
@onready var fullroom_notif = $fullRoomNotif
@onready var kicked_notif = $kickedNotif


# Called when the node enters the scene tree for the first time.
func _ready():
	$joinButton.pressed.connect(_on_join_button_pressed)
	
	if GameManager.last_error == "kicked":
		_show_temp_image(kicked_notif)
		GameManager.last_error = "" 
		
	elif GameManager.last_error == "full":
		_show_temp_image(fullroom_notif)
		GameManager.last_error = ""

func _on_join_button_pressed():
	var code = code_input.text.strip_edges()
	if code == "": return
	GameManager.join_game("127.0.0.1") 
	
	if not multiplayer.connected_to_server.is_connected(_change_to_lobby):
		multiplayer.connected_to_server.connect(_change_to_lobby)
		
func _change_to_lobby():
	get_tree().change_scene_to_file("res://scenes/create_room.tscn")

@rpc("authority")
func receive_error(type):
	if type == "full":
		_show_temp_image(fullroom_notif)
	elif type == "kicked":
		GameManager.last_error = "kicked"
		get_tree().change_scene_to_file("res://scenes/join_room.tscn")

func _show_temp_image(img_node):
	img_node.show()
	await get_tree().create_timer(3.0).timeout
	img_node.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
