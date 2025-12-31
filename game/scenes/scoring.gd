extends Control

@onready var color_label = $colorScore
@onready var scoop_label = $scoopScore
@onready var caffeine_label = $caffeineScore
@onready var time_label = $timeScore
@onready var total_label = $totalScore
@onready var next_button = $nextButton
@onready var waiting_label = $waitingLabel
@onready var killed_label = $killedLabel


func _ready():
	GameManager.calculate_scores()
	
	color_label.text = str(GameManager.score_color) + "/20"
	scoop_label.text = str(GameManager.score_scoops) + "/20"
	caffeine_label.text = str(GameManager.score_caffeine) + "/20"
	time_label.text = str(GameManager.score_time) + "/40"
	total_label.text = str(GameManager.score_total) + "/100"
	
	if GameManager.customer_killed:
		caffeine_label.hide()
		killed_label.show()

	next_button.hide()
	next_button.pressed.connect(_on_next_pressed)
	next_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	next_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	GameManager.notify_player_finished.rpc(
		GameManager.player_name, GameManager.score_total, GameManager.score_color, 
		GameManager.score_scoops, GameManager.score_caffeine, GameManager.score_time, 
		GameManager.customer_killed
	)

func _enable_next_button():
	await get_tree().create_timer(3.0).timeout
	
	waiting_label.hide()
	if multiplayer.is_server(): 
		next_button.show()
	else:
		waiting_label.show()

func _on_next_pressed():
	if multiplayer.is_server(): rpc("goto_leaderboard")

@rpc("authority", "call_local")
func goto_leaderboard():
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")
