extends Control

@export var scoop_full: Texture
@export var scoop_empty: Texture

@onready var boba1 = $boba1
@onready var boba2 = $boba2
@onready var boba3 = $boba3
@onready var boba4 = $boba4
@onready var boba5 = $boba5
@onready var scoop = $scoop
@onready var next_button = $nextButton
@onready var cup_full = $cupFull
@onready var order_popup = $orderPopup
@onready var overlay = $overlay
@onready var close_popup = $orderPopup/closePopup

var scoops = 0
var dragging = false
var has_boba_in_scoop = false
var drag_offset = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cup_full.self_modulate = GameManager.player_color
	
	$orderPopup/targetColor.self_modulate = GameManager.target_color
	$orderPopup/targetScoops.text = str(GameManager.target_scoops)
	$orderPopup/targetCaffeine.text = str(GameManager.target_caffeine) + "%"
	order_popup.hide()
	
	$showOrder.pressed.connect(_on_show_order_pressed)
	close_popup.pressed.connect(_on_close_popup_pressed)
	close_popup.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(close_popup, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	close_popup.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(close_popup, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	next_button.pressed.connect(_on_next_button_pressed)
	next_button.mouse_entered.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(0.8, 0.8, 0.8, 1), 0.1)
	)
	next_button.mouse_exited.connect(func(): 
		var tw = create_tween()
		tw.tween_property(next_button, "self_modulate", Color(1, 1, 1, 1), 0.1)
	)
	
	$scoop/scoopArea.area_entered.connect(_on_scoop_touch)
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if scoop.get_global_rect().has_point(event.global_position):
				dragging = event.pressed
				
				if dragging:
					drag_offset = event.global_position - scoop.global_position
				
	if event is InputEventMouseMotion and dragging:
		scoop.global_position = event.global_position - drag_offset

func _on_show_order_pressed():
	order_popup.show()
	overlay.show()

func _on_close_popup_pressed():
	order_popup.hide()
	overlay.hide()

func _on_scoop_touch(area):
	if area.name == "binArea" and not has_boba_in_scoop:
		has_boba_in_scoop = true
		scoop.texture = scoop_full

	elif area.name == "cup" and has_boba_in_scoop and scoops != 5:
		has_boba_in_scoop = false
		scoop.texture = scoop_empty
		_add_boba()

func _add_boba():
	if scoops == 0:
		boba1.show()
		
	if scoops == 1:
		boba1.hide()
		boba2.show()
		
	if scoops == 2:
		boba2.hide()
		boba3.show()
	
	if scoops == 3:
		boba3.hide()
		boba4.show()
	
	if scoops == 4:
		boba4.hide()
		boba5.show()
	
	scoops = scoops + 1

func _on_next_button_pressed():
	GameManager.player_scoops = scoops
	get_tree().change_scene_to_file("res://scenes/kitchen3.tscn")
