extends Node

@onready var firebase = get_node("/root/Firebase")
const DATABASE_URL = "https://boba-rush-3c9e4-default-rtdb.firebaseio.com/" 
const ROOM_PATH = "rooms/"

const GAME_PORT = 7777
var peer = ENetMultiplayerPeer.new()

signal lobby_created(room_code)
signal lobby_joined
signal lobby_join_failed(reason)
signal player_joined(player_id, player_name)
signal player_left(player_id)

signal new_order_received(order_details)
signal score_updated(player_id, new_score)
signal game_over(winner_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	firebase.init(DATABASE_URL, self)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func host_game():
    var host_ip = ""
    for ip in IP.get_local_addresses():
        if ip.begins_with("192.") or ip.begins_with("10."):
            host_ip = ip
            break
            
    if host_ip == "":
        lobby_join_failed.emit("offline")
        return

    var room_code = str(randi_range(100000, 999999))
    var data = {"ip": host_ip}
    firebase.set_value(ROOM_PATH + room_code, data)
    
    var err = peer.create_server(GAME_PORT)
    if err != OK:
        lobby_join_failed.emit("Could not create server.")
        return
        
    multiplayer.set_multiplayer_peer(peer)
    print("Server created! Your join code is: " + room_code)
    lobby_created.emit(room_code)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
