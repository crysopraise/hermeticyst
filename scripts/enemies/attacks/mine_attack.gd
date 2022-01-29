extends "res://scripts/environment/hazard.gd"

# Constants
export var DURATION = 1

func _ready():
	$Timer.start(DURATION)

func _on_timeout():
	queue_free()

