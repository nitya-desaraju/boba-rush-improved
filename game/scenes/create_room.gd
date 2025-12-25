extends Control

const PLAYER_ROW_SCENE = preload("res://scenes/player_row.tscn")

@onready var code_label = $code
@onready var host_label = $hostName
@onready var round_label = $rounds/round
@onready var player_list = $players
@onready var start_button = $startGameButton
@onready var kick_notif = $kickNotif

func _ready():
	GameManager.players[1] = GameManager.player_name 
	host_label.text = GameManager.player_name
	code_label.text = GameManager.room_code
	
	update_round_display()
	
	if GameManager.is_host:
		start_button.disabled = false
		start_button.modulate = Color(1, 1, 1, 1) 
		$rounds/minus.visible = true
		$rounds/plus.visible = true
	else:
		start_button.disabled = true
		start_button.modulate = Color(0.5, 0.5, 0.5, 1) 
		$rounds/minus.visible = false
		$rounds/plus.visible = false
	
	$rounds/minus.pressed.connect(_on_minus_pressed)
	$rounds/plus.pressed.connect(_on_plus_pressed)
	start_button.pressed.connect(_on_start_game_pressed)
	
	$rounds/minus.mouse_entered.connect(func(): create_tween().tween_property($rounds/minus, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1))
	$rounds/minus.mouse_exited.connect(func(): create_tween().tween_property($rounds/minus, "self_modulate", Color(1, 1, 1, 1), 0.1))
	$rounds/plus.mouse_entered.connect(func(): create_tween().tween_property($rounds/plus, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1))
	$rounds/plus.mouse_exited.connect(func(): create_tween().tween_property($rounds/plus, "self_modulate", Color(1, 1, 1, 1), 0.1))
	start_button.mouse_entered.connect(func(): create_tween().tween_property(start_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1))
	start_button.mouse_exited.connect(func(): create_tween().tween_property(start_button, "self_modulate", Color(1, 1, 1, 1), 0.1))
	
	multiplayer.peer_connected.connect(_on_player_joined)
	multiplayer.peer_disconnected.connect(_update_list_ui)
	_update_list_ui()

func _on_minus_pressed(): 
	if GameManager.max_rounds > 1:
		rpc("sync_rounds", GameManager.max_rounds - 1)

func _on_plus_pressed():
	if GameManager.max_rounds < 5:
		rpc("sync_rounds", GameManager.max_rounds + 1)

@rpc("any_peer", "call_local")
func sync_rounds(value):
	GameManager.max_rounds = value
	update_round_display()

func update_round_display():
	round_label.text = str(GameManager.max_rounds)

func _on_player_joined(id):
	if GameManager.players.size() >= 10:
		rpc_id(id, "receive_error", "full")
		return
	
	await get_tree().create_timer(0.2).timeout
	_update_list_ui()

func _update_list_ui(_id = 0):
	for child in player_list.get_children():
		child.queue_free()
	
	for id in GameManager.players:
		var row = PLAYER_ROW_SCENE.instantiate()
		
		var p_label = row.get_node("row/name") 
		p_label.text = GameManager.players[id]
		

		var kick_btn = row.get_node("row/kickButton")
		kick_btn.mouse_entered.connect(func(): create_tween().tween_property(kick_btn, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1))
		kick_btn.mouse_exited.connect(func(): create_tween().tween_property(kick_btn, "self_modulate", Color(1, 1, 1, 1), 0.1))
		
		if id != 1:
			kick_btn.visible = true
			kick_btn.pressed.connect(func(): _kick_player(id))
		else:
			kick_btn.visible = false
			
		player_list.add_child(row)

func _kick_player(id):
	rpc_id(id, "receive_error", "kicked")
	await get_tree().create_timer(0.1).timeout
	multiplayer.multiplayer_peer.disconnect_peer(id)
	_show_temp_image(kick_notif)

func _show_temp_image(img_node):
	img_node.show()
	await get_tree().create_timer(5.0).timeout
	img_node.hide()

func _on_start_game_pressed():
	rpc("start_the_boba_race")

@rpc("any_peer", "call_local")
func start_the_boba_race():
	get_tree().change_scene_to_file("res://scenes/BobaKitchen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
