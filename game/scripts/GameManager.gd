extends Node

var player_name : String = ""
var room_code : String = ""
var is_host : bool = false
var max_rounds : int = 3
var players : Dictionary = {}
var last_error : String = ""

var peer = WebSocketMultiplayerPeer.new()
const PORT = 8080

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	players.clear()
	players[1] = player_name 

func join_game(ip_address):
	var url = "ws://" + ip_address + ":" + str(PORT)
	peer.create_client(url)
	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server
	var my_id = multiplayer.get_unique_id()
	players[my_id] = player_name

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	rpc_id(id, "register_player", player_name)
	#if multiplayer.is_server():
		#rpc_id(id, "sync_entire_player_list", players)

func _on_peer_disconnected(id):
	if players.has(id):
		players.erase(id)
		_refresh_lobby_ui()

@rpc("any_peer", "reliable", "call_local")
func register_player(new_player_name):
	var id = multiplayer.get_remote_sender_id()
	if id == 0: 
		id = multiplayer.get_unique_id()
	
	players[id] = new_player_name
	if multiplayer.is_server():
		rpc("update_player_list", players)
	
	_refresh_lobby_ui()

@rpc("authority", "reliable")
func update_player_list(new_players_dict):
	players = new_players_dict
	_refresh_lobby_ui()

func _refresh_lobby_ui():
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("_update_list_ui"):
		current_scene._update_list_ui()

@rpc("authority", "reliable")
func sync_entire_player_list(all_players):
	players = all_players
	_refresh_lobby_ui()
