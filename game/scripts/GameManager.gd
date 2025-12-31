extends Node 

var player_name : String = ""
var room_code : String = ""
var is_host : bool = false
var max_rounds : int = 3
var players : Dictionary = {} 
var players_ready_for_leaderboard : Array = []
var last_error : String = ""

var peer = WebSocketMultiplayerPeer.new()
const PORT = 8080

var target_color : Color
var target_scoops : int
var target_caffeine : int

var player_color : Color = Color.WHITE
var player_scoops : int = 0
var player_caffeine : int = 0
var start_time : float = 0.0

var score_color : int = 0
var score_scoops : int = 0
var score_caffeine : int = 0
var score_time : int = 0
var score_total : int = 0
var customer_killed : bool = false

var final_scores : Dictionary = {}
var current_round : int = 1
var cumulative_scores : Dictionary = {}

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	generate_random_order()

func generate_random_order():
	target_color = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
	target_scoops = randi_range(0, 5)
	target_caffeine = randi_range(0, 100)

@rpc("authority", "call_local", "reliable")
func start_game_timer():
	start_time = Time.get_unix_time_from_system()

func calculate_scores():
	customer_killed = false
	var end_time = Time.get_unix_time_from_system()
	var elapsed = int(end_time - start_time)
	score_time = max(0, 40 - elapsed)
	
	var color_diff = (abs(target_color.r - player_color.r) + 
					  abs(target_color.g - player_color.g) + 
					  abs(target_color.b - player_color.b)) / 3.0
	score_color = max(0, int(20 - (40 * color_diff)))
	
	score_scoops = max(0, 20 - (4 * abs(target_scoops - player_scoops)))
	
	var caffeine_diff = player_caffeine - target_caffeine 
	
	if player_caffeine == target_caffeine:
		score_caffeine = 25
		
	elif player_caffeine >= target_caffeine + 10:
		score_caffeine = 0
		customer_killed = true
		
	elif abs(caffeine_diff) <= 5:
		score_caffeine = 20
		
	else:
		score_caffeine = max(0, int(20 - (0.4 * abs(caffeine_diff))))
	
	if customer_killed:
		score_total = 0 
	else:
		score_total = score_color + score_scoops + score_caffeine + score_time
		
	#var my_id = multiplayer.get_unique_id()
	#if not cumulative_scores.has(my_id):
		#cumulative_scores[my_id] = {"name": player_name, "total": 0}
	#
	#cumulative_scores[my_id]["total"] += score_total


@rpc("any_peer", "call_local", "reliable")
func notify_player_finished(p_name, s_total, s_color, s_scoops, s_caffeine, s_time, killed):
	var id = multiplayer.get_remote_sender_id()
	if id == 0: 
		id = multiplayer.get_unique_id()
	
	final_scores[id] = {
		"name": p_name,
		"total": s_total,
		"color": s_color,
		"scoops": s_scoops,
		"caffeine": s_caffeine,
		"time": s_time,
		"killed": killed
	}
	
	if not cumulative_scores.has(id):
		cumulative_scores[id] = {"name": p_name, "total": 0}
	cumulative_scores[id]["total"] += s_total
	
	if not players_ready_for_leaderboard.has(id):
		players_ready_for_leaderboard.append(id)
	
	if multiplayer.is_server():
		check_all_ready()

func check_all_ready():
	if players_ready_for_leaderboard.size() >= players.size():
		rpc("show_host_next_button")

@rpc("authority", "call_local", "reliable")
func start_next_round():
	current_round += 1
	final_scores.clear()
	generate_random_order() 
	players_ready_for_leaderboard.clear() 
	start_game_timer() 
	get_tree().change_scene_to_file("res://scenes/kitchen2.tscn")

@rpc("authority", "call_local", "reliable")
func show_host_next_button():
	var current_scene = get_tree().current_scene
	if current_scene.has_method("_enable_next_button"):
		current_scene._enable_next_button()


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
