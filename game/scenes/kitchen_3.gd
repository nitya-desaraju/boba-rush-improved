extends Control

@onready var slider = $slider
@onready var stop_button = $stopButton
@onready var next_button = $nextButton
@onready var cup = $cup
@onready var order_popup = $orderPopup
@onready var overlay = $overlay

var slider_speed = 120.0
var direction = 1
var is_moving = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cup.self_modulate = GameManager.player_color
	_show_scoops(GameManager.player_scoops)
	
	$orderPopup/targetColor.color = GameManager.target_color
	$orderPopup/targetScoops.text = str(GameManager.target_scoops)
	$orderPopup/targetCaffeine.text = str(GameManager.target_caffeine)
	order_popup.hide()
	
	$showOrder.pressed.connect(_on_show_order_pressed)
	$orderPopup/closePopup.pressed.connect(_on_close_popup_pressed)
	
	next_button.pressed.connect(_on_next_button_pressed)
	next_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	next_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	stop_button.pressed.connect(_on_stop_button_pressed)
	stop_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(stop_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	stop_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(stop_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	

func _process(delta):
	if is_moving:
		slider.value += slider_speed * delta * direction
		
		if slider.value >= slider.max_value or slider.value <= slider.min_value:
			direction *= -1

func _on_show_order_pressed():
	order_popup.show()
	overlay.show()

func _on_close_popup_pressed():
	order_popup.hide()
	overlay.hide()

func _show_scoops(count):
	if count == 1:
		$boba1.show()
		
	if count == 2:
		$boba2.show()
	
	if count == 3:
		$boba3.show()
	
	if count == 4:
		$boba4.show()
		
	if count == 5:
		$boba5.show()

func _on_stop_button_pressed():
	is_moving = false
	stop_button.disabled = true
	GameManager.player_caffeine = int(round(slider.value))


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://scenes/scoring.tscn")
