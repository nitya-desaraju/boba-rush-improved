extends Node 

var player_name : String = ""
var room_code : String = ""
var is_host : bool = false
var max_rounds : int = 3
var players : Dictionary = {}
var last_error : String = ""
var peer = WebSocketMultiplayerPeer.new()
const PORT = 8080


var target_color : Color
var target_scoops : int
var target_caffeine : int

var player_color : Color = Color.WHITE
var player_scoops : int = 0
var player_caffeine : int = 0

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	generate_random_order()

func generate_random_order():

	target_color = Color(randf_range(0.7, 1.0), randf_range(0.7, 1.0), randf_range(0.7, 1.0))
	target_scoops = randi_range(0, 5)
	target_caffeine = randi_range(0, 100)


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

func _on_peer_connected(id):
	rpc_id(id, "register_player", player_name)

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
