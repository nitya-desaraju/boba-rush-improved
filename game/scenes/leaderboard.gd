extends Control 

const LEADERBOARD_ROW = preload("res://scenes/leaderboard_row.tscn")
const FIRST_ROW = preload("res://scenes/first_row.tscn")
const SECOND_ROW = preload("res://scenes/second_row.tscn")
const THIRD_ROW = preload("res://scenes/third_row.tscn")

@onready var list = $ScrollContainer/players
@onready var new_button = $newButton
@onready var menu_button = $menuButton

func _ready():
	_setup_leaderboard()
	
	new_button.visible = multiplayer.is_server()
	new_button.pressed.connect(_on_new_button_pressed)
	_add_hover_tween(new_button)


	menu_button.pressed.connect(_on_menu_button_pressed)
	_add_hover_tween(menu_button)

func _setup_leaderboard():
	for child in list.get_children():
		child.queue_free()
		
	var sorted_players = GameManager.final_scores.values()
	sorted_players.sort_custom(func(a, b): return a["total"] > b["total"])
	
	for i in range(sorted_players.size()):
		var player_data = sorted_players[i]
		var rank = i + 1
		var row
		
		if rank == 1:
			row = FIRST_ROW.instantiate()
		
		elif rank == 2:
			row = SECOND_ROW.instantiate()
			
		elif rank == 3:
			row = THIRD_ROW.instantiate()
		
		else:
			row = LEADERBOARD_ROW.instantiate()
			
		list.add_child(row)
		var name_label = row.find_child("name")
		var score_label = row.find_child("score")
		
		if name_label:
			name_label.text = player_data["name"]
			if player_data["name"] == GameManager.player_name:
				name_label.bbcode_enabled = true
				name_label.text = "[b][i]" + player_data["name"] + "[/i][/b]"
				
		if score_label:
			score_label.text = str(player_data["total"])

func _on_new_button_pressed():
	rpc("sync_new_game")

@rpc("authority", "call_local", "reliable")
func sync_new_game():
	get_tree().change_scene_to_file("res://scenes/create_room.tscn")

func _on_menu_button_pressed():
	if multiplayer.is_server():
		rpc("sync_return_to_opening")
	else:
		get_tree().change_scene_to_file("res://scenes/opening.tscn")

@rpc("authority", "call_local", "reliable")
func sync_return_to_opening():
	multiplayer.multiplayer_peer = null 
	get_tree().change_scene_to_file("res://scenes/opening.tscn")

func _add_hover_tween(btn):
	btn.mouse_entered.connect(func(): 
		create_tween().tween_property(btn, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	btn.mouse_exited.connect(func(): 
		create_tween().tween_property(btn, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
