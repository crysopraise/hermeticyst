extends Spatial

# Constants
export var HAS_KNOCKBACK = false
export var DAMAGE = 2

# Variables
var blood_level = 4

func _ready():
	connect("body_entered", self, "_on_collision")

func add_blood_level(value):
	blood_level = min(blood_level + value, 1)

func set_blood_level(value):
	blood_level = value

func _on_collision(body):
	body.die()

