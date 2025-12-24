extends Node

var player_name : String = ""
var room_code : String = ""
var is_host : bool = false
var max_rounds : int = 3
var players : Dictionary = {} 

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
