extends Control

@export var cup_empty_texture: Texture2D
@export var cup_with_boba_texture: Texture2D

@onready var order_popup: PanelContainer = $OrderPopup
@onready var close_button: Button = $OrderPopup/CloseButton
@onready var minimized_order_button: Button = $MinimizedOrderButton
@onready var boba_container: Button = $BobaContainer
@onready var cup_image: TextureRect = $CupImage


var current_boba_scoops = 0
const MAX_BOBA_SCOOPS = 5


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	minimized_order_button.pressed.connect(_on_minimized_order_button_pressed)
	boba_container.pressed.connect(_on_boba_container_pressed)
	
	order_popup.show()
	minimized_order_button.hide()
	
	cup_image.texture = cup_empty_texture
	current_boba_scoops = 0


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
