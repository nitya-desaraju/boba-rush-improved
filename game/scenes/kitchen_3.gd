extends Control 

@onready var slider = $slider
@onready var stop_button = $stopButton
@onready var pour_button = $pourButton
@onready var next_button = $nextButton
@onready var cup = $cup

var slider_speed = 100.0
var direction = 1
var is_moving = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cup.self_modulate = current_color
	
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
	
	pour_button.pressed.connect(_on_pour_button_pressed)
	pour_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(pour_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	pour_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(pour_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	pour_button.disabled = true 


func _process(delta):
	if is_moving:
		slider.value += slider_speed * delta * direction
		
		if slider.value >= slider.max_value or slider.value <= slider.min_value:
			direction *= -1


func _on_stop_button_pressed():
	is_moving = false
	stop_button.disabled = true
	pour_button.disabled = false 


func _on_pour_button_pressed():
	pour_button.disabled = true 
	play_pouring_animation()

func play_pouring_animation():
	await get_tree().create_timer(2.0).timeout 


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://scenes/scoring.tscn")
