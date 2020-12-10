extends Node

export var LIFETIME = 1

func _ready():
	yield(get_tree().create_timer(LIFETIME), "timeout")
	queue_free()
