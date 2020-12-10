extends Node

export var SCALE_FACTOR = 4

func _ready():
	OS.set_window_size(Vector2(OS.window_size.x * SCALE_FACTOR, OS.window_size.y * SCALE_FACTOR))
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
