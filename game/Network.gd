extends Node

signal lobby_created(room_code)
signal lobby_joined
signal lobby_join_failed(reason)
signal player_joined(player_id, player_info)
signal player_left(player_id)
signal host_started_game

signal game_started(total_rounds)
signal round_started(round_number, order_details)
signal round_ended(scores, current_leaderboard)
signal game_over_by_customer_death(killing_player_id, player_name, final_scores)
signal game_over_normally(final_scores)

const ROOM_PATH = "rooms/"
const GAME_PORT = 7777

const MAX_PLAYERS = 10
const MAX_NAME_LENGTH = 20

@onready var firebase = get_node("/root/Firebase")
var peer = ENetMultiplayerPeer.new()
var local_player_name = "Player"

enum GameState { LOBBY, IN_GAME, ROUND_END, GAME_OVER }
var current_state = GameState.LOBBY
var total_rounds = 3
var current_round = 0

var players = {}
var killing_player_trigger_id = -1
var current_order_details = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func set_player_name(new_name: String):
	if new_name.length() > MAX_NAME_LENGTH:
		local_player_name = new_name.substr(0, MAX_NAME_LENGTH)
	else:
		local_player_name = new_name

func host_game():
	var host_ip = ""
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10."):
			host_ip = ip
			break
			
	if host_ip == "":
		print("Error: Could not find a local IP. Are you connected to a network?")
		lobby_join_failed.emit("offline")
		return

	var room_code = str(randi_range(100000, 999999))
	var data = {"ip": host_ip}
	firebase.set_value(ROOM_PATH + room_code, data)
	
	var err = peer.create_server(GAME_PORT, MAX_PLAYERS - 1)
	
	if err != OK:
		print("Error: Could not create server.")
		lobby_join_failed.emit("Could not create server.")
		return
		
	multiplayer.set_multiplayer_peer(peer)
	print("Server created! Your join code is: " + room_code)
	
	_register_player_locally(1, local_player_name)
	lobby_created.emit(room_code)

func join_game(room_code):
	print("Attempting to join room: " + room_code)
	var result = await firebase.get_value(ROOM_PATH + room_code)

	if result == null or not result.has("ip"):
		print("Error: Room not found.")
		lobby_join_failed.emit("Room not found!")
		return

	var host_ip = result.get("ip")
	
	print("Room found! Connecting to host at " + host_ip)
	var err = peer.create_client(host_ip, GAME_PORT)
	if err != OK:
		print("Error: Could not connect to host.")
		lobby_join_failed.emit("Could not connect to host.")
		return
		
	multiplayer.set_multiplayer_peer(peer)

func _on_player_connected(id):
	print("Player connected: " + str(id))

func _on_player_disconnected(id):
	print("Player disconnected: " + str(id))
	if players.has(id):
		players.erase(id)
		player_left_rpc.call(id)
		player_left.emit(id)

func _on_server_disconnected():
	print("Disconnected from server.")
	multiplayer.set_multiplayer_peer(null)
	players.clear()
	current_state = GameState.LOBBY
	lobby_join_failed.emit("Lost connection to host.")

func _register_player_locally(id, player_name):
	var player_info = {
		"name": player_name,
		"score": 0,
		"finished_round": false,
		"customer_dead": false
	}
	players[id] = player_info
	player_joined.emit(id, player_info)

@rpc("any_peer", "call_local")
func client_register_info(player_name):
	var id = multiplayer.get_remote_sender_id()

	if players.size() >= MAX_PLAYERS:
		print("Host: Player %d tried to join, but the room is full. Kicking." % id)
		peer.disconnect_peer(id)
		return

	print("Host: Registering player %d: %s" % [id, player_name])
	
	var final_player_name = player_name
	if final_player_name.length() > MAX_NAME_LENGTH:
		final_player_name = final_player_name.substr(0, MAX_NAME_LENGTH)
	
	_register_player_locally(id, final_player_name)
	player_joined_rpc.call(id, players[id])
	rpc_id(id, "sync_full_player_list_rpc", players)

@rpc("authority")
func player_joined_rpc(id, player_info):
	if id == multiplayer.get_unique_id():
		return
	print("Client: Adding new player %d to local list" % id)
	players[id] = player_info
	player_joined.emit(id, player_info)

@rpc("authority")
func sync_full_player_list_rpc(all_players):
	print("Client: Successfully joined lobby. Syncing all players.")
	players = all_players
	lobby_joined.emit()

@rpc("authority")
func player_left_rpc(id):
	if players.has(id):
		print("Client: Player %d left." % id)
		players.erase(id)
		player_left.emit(id)

func start_game(num_rounds: int):
	if not multiplayer.is_server():
		return
		
	print("Host is starting the game with %d rounds." % num_rounds)
	total_rounds = num_rounds
	current_round = 0
	current_state = GameState.IN_GAME
	
	start_game_rpc.call(total_rounds)
	host_started_game.emit()
	_start_next_round()

@rpc("authority")
func start_game_rpc(num_rounds):
	total_rounds = num_rounds
	current_state = GameState.IN_GAME
	game_started.emit(total_rounds)
	print("Client: Game started! %d rounds." % total_rounds)

func _start_next_round():
	if not multiplayer.is_server():
		return
		
	killing_player_trigger_id = -1
	current_round += 1
	print("Host starting round %d" % current_round)
	
	for id in players:
		if not players[id]["customer_dead"]:
			players[id]["finished_round"] = false
			
	current_order_details = {
		"drink_name": "Caffeine Bomb",
		"target_caffeine": 2.0,
		"target_sweetness": 1.0,
		"max_caffeine": 3.0
	}
	
	start_round_rpc.call(current_round, current_order_details)
	
@rpc("authority")
func start_round_rpc(round_num, order):
	current_round = round_num
	current_state = GameState.IN_GAME
	print("Client: Round %d started." % current_round)
	round_started.emit(current_round, order)

@rpc("any_peer", "call_local")
func client_finished_drink(drink_data):
	var id = multiplayer.get_remote_sender_id()
	
	if not players.has(id) or players[id]["finished_round"]:
		return
		
	print("Host: Received finished drink from player %d" % id)
	players[id]["finished_round"] = true
	
	var time_taken = float(drink_data.get("time_taken", 50.0))
	var time_score = clamp(50.0 - time_taken, 0.0, 50.0)

	var caffeine_val = float(drink_data.get("caffeine", 0.0))
	var sweetness_val = float(drink_data.get("sweetness", 0.0))
	
	var target_caffeine = float(current_order_details.get("target_caffeine", 2.0))
	var target_sweetness = float(current_order_details.get("target_sweetness", 1.0))
	
	var caffeine_diff = abs(caffeine_val - target_caffeine)
	var sweetness_diff = abs(sweetness_val - target_sweetness)
	
	var total_diff = caffeine_diff + sweetness_diff
	var accuracy_score = clamp(50.0 - (total_diff * 10.0), 0.0, 50.0)
	
	var score_for_this_round = roundi(time_score + accuracy_score)
	
	var max_caffeine = float(current_order_details.get("max_caffeine", 3.0))
	var customer_died = (caffeine_val > max_caffeine)
	
	if customer_died:
		print("Host: Player %d's customer died! (It's a secret...)" % id)
		players[id]["customer_dead"] = true
		players[id]["score"] = 0
		killing_player_trigger_id = id
	else:
		players[id]["score"] += score_for_this_round
	
	_check_if_round_over()

func _check_if_round_over():
	if not multiplayer.is_server():
		return

	var all_finished = true
	for id in players:
		if not players[id]["customer_dead"] and not players[id]["finished_round"]:
			all_finished = false
			break
			
	if all_finished:
		print("Host: All players finished round %d." % current_round)
		_end_round()

func _end_round():
	current_state = GameState.ROUND_END
	
	if killing_player_trigger_id != -1:
		print("Host: Round ending with a customer death. Triggering jumpscare.")
		_end_game_due_to_customer_death(killing_player_trigger_id)
	else:
		print("Host: Round ending normally. Showing scores.")
		end_round_rpc.call(players)
		
		await get_tree().create_timer(5.0).timeout
		
		if current_round >= total_rounds:
			_end_game_normally()
		else:
			_start_next_round()

func _end_game_normally():
	current_state = GameState.GAME_OVER
	print("Host: Game over normally.")
	game_over_normally_rpc.call(players)

func _end_game_due_to_customer_death(killing_player_id):
	current_state = GameState.GAME_OVER
	print("Host: Game over due to customer death by player %d" % killing_player_id)
	var player_name = players[killing_player_id]["name"]
	
	game_over_by_customer_death_rpc.call(killing_player_id, player_name, players)

@rpc("authority")
func end_round_rpc(all_player_data):
	current_state = GameState.ROUND_END
	players = all_player_data
	round_ended.emit(players, players)
	print("Client: Round ended. Showing scores.")

@rpc("authority")
func game_over_normally_rpc(final_scores):
	current_state = GameState.GAME_OVER
	players = final_scores
	game_over_normally.emit(final_scores)
	print("Client: Game over normally.")

@rpc("authority")
func game_over_by_customer_death_rpc(killing_player_id, player_name, final_scores):
	current_state = GameState.GAME_OVER
	players = final_scores
	game_over_by_customer_death.emit(killing_player_id, player_name, final_scores)
	print("Client: Game over by CUSTOMER DEATH!")
