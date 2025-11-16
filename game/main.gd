extends Control

@export var cup_empty_texture: Texture2D
@export var cup_with_boba_texture: Texture2D

@onready var order_popup: PanelContainer = $"Order-sign"
@onready var close_button: Button = $ShowOrderButton
@onready var minimized_order_button: Button = $ShowOrderButton #might give error
@onready var boba_container: Button = $BobaBin
@onready var cup_image: TextureRect = $EmptyCup

@onready var red_slider: HSlider = $"Red-bottle/HSlider3"
@onready var green_slider: HSlider = $"Green-bottle/HSlider2"
@onready var blue_slider: HSlider = $"Blue-bottle/HSlider"
@onready var color_preview: ColorRect = $ColorPreview
@onready var dispense_button: Button = $DispenseButton

@onready var caffeine_slider: HSlider = $CaffeineSlider
@onready var caffeine_stop_button: Button = $CaffeineStopButton
@onready var yellow_zone: ColorRect = $TrackContainer/YellowZone
@onready var green_zone: ColorRect = $TrackContainer/GreenZone
@onready var red_zone: ColorRect = $TrackContainer/RedZone

const CAFFEINE_SLIDER_MAX = 80.0
const MAX_BOBA_SCOOPS = 5

var current_boba_scoops = 0
var current_color = Color.WHITE
var current_caffeine = 0.0

var _caffeine_slider_speed = 40.0 
var _caffeine_slider_direction = 1
var _caffeine_game_active = false


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	minimized_order_button.pressed.connect(_on_minimized_order_button_pressed)
	boba_container.pressed.connect(_on_boba_container_pressed)
	
	red_slider.value_changed.connect(_on_color_slider_changed)
	green_slider.value_changed.connect(_on_color_slider_changed)
	blue_slider.value_changed.connect(_on_color_slider_changed)
	dispense_button.pressed.connect(_on_dispense_button_pressed)
	
	caffeine_stop_button.pressed.connect(_on_caffeine_stop_button_pressed)
	

	Network.round_started.connect(_on_round_started)
	
	caffeine_slider.max_value = CAFFEINE_SLIDER_MAX
	

	order_popup.show()
	minimized_order_button.hide()
	

	cup_image.texture = cup_empty_texture
	cup_image.modulate = Color.WHITE
	current_boba_scoops = 0
	

	_update_color_preview()


func _process(delta: float) -> void:
	if _caffeine_game_active:
		var new_value = caffeine_slider.value + (_caffeine_slider_speed * _caffeine_slider_direction * delta)
		
		if new_value >= caffeine_slider.max_value:
			new_value = caffeine_slider.max_value
			_caffeine_slider_direction = -1
		elif new_value <= caffeine_slider.min_value:
			new_value = caffeine_slider.min_value
			_caffeine_slider_direction = 1
		
		caffeine_slider.value = new_value

func _on_round_started(round_num: int, order: Dictionary) -> void:
	var target_caffeine = order.get("target_caffeine", 40.0)
	_update_caffeine_track(target_caffeine)
	_reset_caffeine_game()

func _on_close_button_pressed() -> void:
	order_popup.hide()
	minimized_order_button.show()

func _on_minimized_order_button_pressed() -> void:
	order_popup.show()
	minimized_order_button.hide()

func _on_boba_container_pressed() -> void:
	if current_boba_scoops < MAX_BOBA_SCOOPS:
		current_boba_scoops += 1
		print("Boba scoops: %d" % current_boba_scoops)
		
		if current_boba_scoops == 1:
			cup_image.texture = cup_with_boba_texture
	else:
		print("Max boba scoops reached!")

func _on_color_slider_changed(value: float) -> void:
	_update_color_preview()

func _on_dispense_button_pressed() -> void:
	cup_image.modulate = current_color
	print("Dispensed color: %s" % current_color)

func _on_caffeine_stop_button_pressed() -> void:
	_caffeine_game_active = false
	current_caffeine = caffeine_slider.value
	caffeine_stop_button.disabled = true
	print("Caffeine stopped at: %f" % current_caffeine)


func _update_caffeine_track(target: float) -> void:
	var green_start_val = target * 0.95
	var red_start_val = target * 1.05
	
	if target == 0.0:
		red_start_val = 0.5 
	
	var slider_width_px = caffeine_slider.size.x
	
	var green_start_px = (green_start_val / CAFFEINE_SLIDER_MAX) * slider_width_px
	var red_start_px = (red_start_val / CAFFEINE_SLIDER_MAX) * slider_width_px

	yellow_zone.position.x = 0
	yellow_zone.size.x = green_start_px

	green_zone.position.x = green_start_px
	green_zone.size.x = red_start_px - green_start_px
	
	red_zone.position.x = red_start_px
	red_zone.size.x = slider_width_px - red_start_px

func _update_color_preview() -> void:
	var r = red_slider.value
	var g = green_slider.value
	var b = blue_slider.value
	
	current_color = Color(r / 255.0, g / 255.0, b / 255.0)
	
	color_preview.color = current_color

func _reset_caffeine_game() -> void:
	_caffeine_game_active = true
	caffeine_stop_button.disabled = false
	caffeine_slider.value = caffeine_slider.min_value
	_caffeine_slider_direction = 1
	current_caffeine = 0.0
