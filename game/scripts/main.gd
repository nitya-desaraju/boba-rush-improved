extends Control

@onready var order_popup: PanelContainer = $OrderPopup
@onready var close_button: Button = $OrderPopup/CloseButton
@onready var minimized_order_button: Button = $MinimizedOrderButton


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	minimized_order_button.pressed.connect(_on_minimized_order_button_pressed)
	
	order_popup.show()
	minimized_order_button.hide()

func _on_close_button_pressed() -> void:
	order_popup.hide()
	minimized_order_button.show()

func _on_minimized_order_button_pressed() -> void:
	order_popup.show()
	minimized_order_button.hide()