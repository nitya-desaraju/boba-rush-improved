extends Node

var player_name : String = ""
var room_code : String = ""
var is_host : bool = false
var max_rounds : int = 3
var players : Dictionary = {}
var last_error : String = ""

var peer = WebSocketMultiplayerPeer.new()
const PORT = 8080
const ADDRESS = "127.0.0.1" 

func host_game():
	var error = peer.create_server(PORT)
	if error != OK:
		print("hosting failed")
		return
	multiplayer.multiplayer_peer = peer
	players[1] = player_name 

func join_game(ip_address):
	var url = "ws://" + ip_address + ":" + str(PORT)
	
	var error = peer.create_client(url) 
	if error != OK:
		print("joining failed")
		return
	multiplayer.multiplayer_peer = peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func _on_peer_connected(id):
	if multiplayer.is_server():
		rpc_id(id, "send_full_player_list", players)
	
	rpc_id(id, "register_player", player_name)

@rpc("any_peer", "reliable")
func register_player(new_player_name):
	var id = multiplayer.get_remote_sender_id()
	if id == 0: id = 1
	players[id] = new_player_name
	_refresh_lobby_ui()

@rpc("authority", "reliable")
func send_full_player_list(all_players):
	players = all_players
	_refresh_lobby_ui()

func _refresh_lobby_ui():
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("_update_list_ui"):
		current_scene._update_list_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
