extends Control

@onready var winner_title_label: Label = $WinnerTitleLabel
@onready var winner_name_label: Label = $WinnerNameLabel
@onready var host_buttons: HBoxContainer = $HostButtons
@onready var play_again_button: Button = $HostButtons/PlayAgainButton
@onready var return_home_button: Button = $HostButtons/ReturnHomeButton

func _ready() -> void:
	Network.show_winner_screen.connect(_on_show_winner_screen)
	
	play_again_button.pressed.connect(_on_play_again_pressed)
	return_home_button.pressed.connect(_on_return_home_pressed)
	
	host_buttons.hide()
	
func _on_show_winner_screen(final_scores: Dictionary) -> void:
	var sorted_players = final_scores.values()
	sorted_players.sort_custom(func(a, b): return a.score > b.score)
	
	if sorted_players.size() > 0:
		winner_name_label.text = sorted_players[0].name
	else:
		winner_name_label.text = "Nobody!"
	
	if multiplayer.is_server():
		host_buttons.show()

func _on_play_again_pressed() -> void:
	Network.host_request_play_again()

func _on_return_home_pressed() -> void:
	Network.host_request_return_to_home()