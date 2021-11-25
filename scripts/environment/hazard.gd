extends Spatial

# Variables
var blood_level = 0

func add_blood_level(value):
	blood_level = min(blood_level + value, 1)

func set_blood_level(value):
	blood_level = value

func _on_collision(body):
	body.die()

