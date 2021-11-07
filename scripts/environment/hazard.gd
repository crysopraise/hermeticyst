extends Spatial

# Variables
var blood_level = 0

func set_blood_level(value):
	blood_level = value

func _on_collision(body):
	body.die()

