extends Control 

#@export var cup_empty: Texture
#@export var cup_half1: Texture
#@export var cup_half2: Texture
#@export var cup_half3: Texture
#@export var cup_full: Texture

@onready var color_viewer = $colorViewer
@onready var red_slider = $colorViewer/redSlider
@onready var green_slider = $colorViewer/greenSlider
@onready var blue_slider = $colorViewer/blueSlider
@onready var cup_empty = $cupEmpty
@onready var cup_half1 = $cupHalf1
@onready var cup_half2 = $cupHalf2
@onready var cup_half3 = $cupHalf3
@onready var cup_full = $cupFull
@onready var next_button = $nextButton
@onready var order_popup = $orderPopup
@onready var target_color = $orderPopup/targetColor
@onready var submit_btn = $colorViewer/submitButton

var current_color: Color = Color.WHITE

func _ready():
	submit_btn.pressed.connect(_on_submit_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	$showOrder.pressed.connect(_on_show_order_pressed)
	$orderPopup/closePopup.pressed.connect(_on_close_popup_pressed) 

	next_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	next_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	submit_btn.mouse_entered.connect(func(): 
		if not submit_btn.disabled:
			var tw = create_tween()
			tw.tween_property(submit_btn, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	submit_btn.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(submit_btn, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	for slider in [red_slider, green_slider, blue_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value_changed.connect(_on_slider_changed)
	
	#cup.texture = cup_empty
	next_button.hide()
	order_popup.hide()
	_generate_order()

func _on_slider_changed(_value):
	current_color = Color(red_slider.value, green_slider.value, blue_slider.value)
	color_viewer.self_modulate = current_color

func _on_show_order_pressed():
	order_popup.show()

func _on_close_popup_pressed():
	order_popup.hide()

func _generate_order():
	var r = randf_range(0.7, 1.0)
	var g = randf_range(0.7, 1.0)
	var b = randf_range(0.7, 1.0)
	target_color.color = Color(r, g, b)

func _on_submit_button_pressed():
	$colorViewer/submitButton.disabled = true
	_play_pour_animation()

func _play_pour_animation():
	cup_half1.self_modulate = current_color
	cup_half2.self_modulate = current_color
	cup_half3.self_modulate = current_color
	cup_full.self_modulate = current_color
	
	await get_tree().create_timer(0.5).timeout
	cup_empty.hide()
	cup_half1.show()
	
	await get_tree().create_timer(0.5).timeout
	cup_half1.hide()
	cup_half2.show()
	
	await get_tree().create_timer(0.5).timeout
	cup_half2.hide()
	cup_half3.show()
	
	await get_tree().create_timer(0.5).timeout
	cup_half3.hide()
	cup_full.show()
	
	await get_tree().create_timer(0.5).timeout
	next_button.show()

#func _play_pour_animation():
	#cup.self_modulate = current_color
	#
	#await get_tree().create_timer(0.5).timeout
	#cup.texture = cup_half1
	#cup.self_modulate = current_color
	#
	#await get_tree().create_timer(0.5).timeout
	#cup.texture = cup_half2
	#cup.self_modulate = current_color
	#
	#await get_tree().create_timer(0.5).timeout
	#cup.texture = cup_half3
	#cup.self_modulate = current_color
	#
	#await get_tree().create_timer(0.5).timeout
	#cup.texture = cup_full
	#cup.self_modulate = current_color
	#
	#next_button.show()
	
func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://scenes/kitchen2.tscn")
