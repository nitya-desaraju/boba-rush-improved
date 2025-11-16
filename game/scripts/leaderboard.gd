extends Control

@export var score_entry_scene: PackedScene

@onready var title_label: Label = $TitleLabel
@onready var score_list_container: VBoxContainer = $ScoreListContainer
@onready var jumpscare_container: Control = $JumpscareContainer
@onready var video_player: VideoPlayer = $JumpscareContainer/VideoPlayer
@onready var death_message_label: Label = $JumpscareContainer/DeathMessageLabel
@onready var jumpscare_timer: Timer = $JumpscareTimer
@onready var host_next_button: Button = $HostNextButton
@onready var player_rank_label: Label = $PlayerRankLabel

var _temp_final_scores: Dictionary
var _temp_player_name: String


func _ready() -> void:
	NetworkManager.round_ended.connect(_on_round_ended)
	NetworkManager.game_over_normally.connect(_on_game_over_normally)
	NetworkManager.game_over_by_customer_death.connect(_on_game_over_by_death)
	
	jumpscare_timer.timeout.connect(_on_jumpscare_timer_timeout)
	host_next_button.pressed.connect(_on_host_next_button_pressed)
	
	_hide_all()


func _hide_all() -> void:
	title_label.hide()
	score_list_container.hide()
	jumpscare_container.hide()
	death_message_label.hide()
	video_player.hide()
	host_next_button.hide()
	player_rank_label.hide()


func _on_round_ended(scores: Dictionary, leaderboard: Dictionary) -> void:
	_hide_all()
	title_label.text = "Round %d Complete!" % NetworkManager.current_round
	_populate_leaderboard(leaderboard)
	
	title_label.show()
	score_list_container.show()
	
	if multiplayer.is_server():
		host_next_button.text = "Next Drink"
		host_next_button.show()
	
	print("Leaderboard: Showing normal round scores")


func _on_game_over_normally(final_scores: Dictionary) -> void:
	_hide_all()
	title_label.text = "Game Over! Final Scores:"
	_populate_leaderboard(final_scores, true)
	
	title_label.show()
	score_list_container.show()
	
	if multiplayer.is_server():
		host_next_button.text = "Show Winner"
		host_next_button.show()

	print("Leaderboard: Showing FINAL scores")


func _on_game_over_by_death(killing_player_id: int, player_name: String, final_scores: Dictionary, jumpscare_video_index: int) -> void:
	_hide_all()
	print("Leaderboard: JUMPSCARE triggered!")

	_temp_final_scores = final_scores
	_temp_player_name = player_name

	var video_path = NetworkManager.JUMPSCARE_VIDEOS[jumpscare_video_index]
	video_player.stream = load(video_path)
	video_player.play()
	
	jumpscare_container.show()
	video_player.show()
	
	jumpscare_timer.wait_time = 3.0
	jumpscare_timer.start()


func _on_jumpscare_timer_timeout() -> void:
	if video_player.is_playing():
		video_player.stop()
		video_player.hide()
		
		death_message_label.text = "%s's customer has DIED!" % _temp_player_name
		death_message_label.show()
		
		jumpscare_timer.wait_time = 3.0
		jumpscare_timer.start()
	else:
		_show_final_leaderboard_after_jumpscare()


func _show_final_leaderboard_after_jumpscare() -> void:
	print("Leaderboard: Showing scores after jumpscare.")
	jumpscare_container.hide()
	
	title_label.text = "Game Over! Final Scores:"
	_populate_leaderboard(_temp_final_scores, true)
	
	title_label.show()
	score_list_container.show()
	
	if multiplayer.is_server():
		host_next_button.text = "Show Winner"
		host_next_button.show()


func _on_host_next_button_pressed() -> void:
	host_next_button.hide()
	
	if host_next_button.text == "Next Drink":
		NetworkManager.host_request_next_round()
	elif host_next_button.text == "Show Winner":
		NetworkManager.host_request_winner_screen()


func _populate_leaderboard(player_data_dict: Dictionary, show_winner: bool = false) -> void:
	for child in score_list_container.get_children():
		child.queue_free()

	var sorted_players = player_data_dict.values()
	sorted_players.sort_custom(func(a, b): return a.score > b.score)
	
	var local_player_id = multiplayer.get_unique_id()
	var local_player_rank = -1
	var local_player_score = 0

	for i in range(sorted_players.size()):
		if sorted_players[i].id == local_player_id:
			local_player_rank = i + 1
			local_player_score = sorted_players[i].score
			break
	
	for i in range(5):
		var entry = score_entry_scene.instantiate()
		var rank_text = "#%d" % (i + 1)
		var name_text = "---"
		var score_text = "---"
		
		var is_winner = false
		var is_dead = false

		if i < sorted_players.size():
			var player = sorted_players[i]
			name_text = player.name
			score_text = str(player.score)
			
			if show_winner and i == 0:
				is_winner = true
			
			if player.customer_dead:
				is_dead = true
				score_text = "DEAD"
		
		entry.get_node("RankLabel").text = rank_text
		entry.get_node("NameLabel").text = name_text
		entry.get_node("ScoreLabel").text = score_text
		
		if is_winner:
			entry.get_node("NameLabel").modulate = Color.GOLD
		
		if is_dead:
			entry.get_node("NameLabel").modulate = Color.RED

		score_list_container.add_child(entry)

	if local_player_rank > 5:
		player_rank_label.text = "Your Rank: #%d (Score: %d)" % [local_player_rank, local_player_score]
		player_rank_label.show()
	elif local_player_rank == -1:
		player_rank_label.text = "You are not in the ranking."
		player_rank_label.show()
	else:
		player_rank_label.hide()