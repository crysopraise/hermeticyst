extends Area

# Constants
export var SPEED = 5
export var SIZE = 1
export var KILL_TIME = 15

var DISTANCE_MAX = 0

# Variables
var move_forward = true
var is_destroyable = false
var first_update = true
var speed = SPEED
var distance_traveled = 0
var is_dead = true

func init(params: Dictionary = {}):
#	speed = params.get('speed', SPEED)
#	DISTANCE_MAX = speed * params.get('kill_time', KILL_TIME)
#	move_forward = params.get('move_forward', true)
#	is_destroyable = params.get('is_destroyable', false)
#	if is_destroyable:
#		$MeshInstance.mesh.material.albedo_color = Color.yellow
#		$MeshInstance.mesh.material.emission_energy = 0.1
#
	die()
	return self

func _ready():
	die() # Begin as inactive when added to the scene

func _physics_process(delta):
	move(delta)

func move(delta):
	var distance = speed * delta
	translate((Vector3.FORWARD if move_forward else Vector3.BACK) * distance)
	update_distance_traveled(distance)

func update_distance_traveled(distance):
	distance_traveled += distance
	if distance_traveled >= DISTANCE_MAX:
		die()

func fire(params):
	$CollisionShape.disabled = false
	monitoring = true
	distance_traveled = 0
	translation = params.position
	look_at(translation + params.direction, Vector3.UP)
	$CollisionShape.scale = Vector3.ONE * params.get('size', SIZE)
	$MeshInstance.scale = Vector3.ONE * params.get('size', SIZE)
	move_forward = params.get('move_forward', true)
	speed = params.get('speed', SPEED)
	DISTANCE_MAX = speed * params.get('kill_time', KILL_TIME)
	is_destroyable = params.get('is_destroyable', false)
	if is_destroyable:
		$MeshInstance.mesh.material.albedo_color = Color.yellow
		$MeshInstance.mesh.material.emission_energy = 0.1
	set_physics_process(true)
	$MeshInstance.show()
	is_dead = false

func delayed_fire(params, delay):
	$DelayShot.connect('timeout', self, 'fire', [params], Object.CONNECT_ONESHOT)
	$DelayShot.start(delay)

func die():
	set_physics_process(false)
	$CollisionShape.disabled = true
	$MeshInstance.hide()
	monitoring = false
	is_dead = true

func _on_hit_player(area):
	# Collide with player bullet hitbox
	if area.collision_layer & 16:
		area.get_parent().die()

func _on_hit_environment(_body):
	die()

