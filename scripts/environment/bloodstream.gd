extends "res://scripts/environment/hazard.gd"

# Constants
var MIN_RADIUS: float = 0
var MAX_RADIUS: float = 6

func _ready():
	update_mesh(MIN_RADIUS)
	update_collision(MIN_RADIUS)

func set_blood_level(value):
	print('set blood level ', value)
	.set_blood_level(value)
	var radius = MIN_RADIUS + ((MAX_RADIUS - MIN_RADIUS) * value)
	update_mesh(radius)
	update_collision(radius)

func update_mesh(radius):
	$Mesh.mesh.top_radius = radius
	$Mesh.mesh.bottom_radius = radius

func update_collision(radius):
	if radius == 0:
		radius = 0.01
		$CollisionShape.disabled = true
	elif $CollisionShape.disabled:
		$CollisionShape.disabled = false
	$CollisionShape.shape.radius = radius

