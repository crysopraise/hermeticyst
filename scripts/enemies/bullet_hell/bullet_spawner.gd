extends Spatial

# Constants
export var spawn_point_count = 20
export var radius = 4.0
export var rotation_speed = 2
export var rotate_cos = true
export var has_multiple_spawns = true
export var bullet_name = "bullet"
export var BULLET_SPEED = 5
export var BULLET_SIZE = 1
export var BULLET_KILL_TIME = 5
export var BULLET_MOVE_FORWARD = false
export var SHOOT_INTERVAL = 0.25
export var ATTACK_DURATION = 3
export var COOLDOWN_TIME = 5

# Scenes
var bullet_scn

# Variables
onready var base_rotation = rotation
var time = 0
var is_shooting = false

func _ready():
	if has_multiple_spawns:
		create_spawns()
	$ShootTimer.wait_time = SHOOT_INTERVAL
	$AttackTimer.wait_time = ATTACK_DURATION
	$CooldownTimer.wait_time = COOLDOWN_TIME
	BulletManager.create_pool(bullet_name)

func _physics_process(delta):
	if is_shooting:
		shoot_state(delta)

func shoot_state(delta):
	if rotate_cos:
		time += delta / 2
		rotation.y = base_rotation.y + cos(time)
		rotation.x = base_rotation.x + cos(time)
	else:
		var rot = delta / 2
		rotate_y(rot)
		rotate_x(rot)

func _on_shoot():
	for s in $SpawnContainer.get_children():
		BulletManager.fire_bullet(bullet_name, {
			'position': s.global_transform.origin,
			'direction': s.global_transform.origin.direction_to(global_transform.origin),
			'speed': BULLET_SPEED,
			'kill_time': BULLET_KILL_TIME,
			'move_forward': false})

func stop_attack():
	$ShootTimer.stop()
	is_shooting = false

func start_attack():
	$ShootTimer.start()
	is_shooting = true

func create_spawns():
	for p in get_spawn_points(spawn_point_count, radius):
		var spawn_point = Spatial.new()
		$SpawnContainer.add_child(spawn_point)
		spawn_point.transform = Transform(Basis.IDENTITY, p)

func get_spawn_points(count=1, sphere_radius=1):
	var points = []
	var phi = PI * (3.0 - sqrt(5.0))

	for i in range(count):
		var y = 1 - (i / float(count - 1)) * 2
		var radius = sqrt(1 - y * y)

		var theta = phi * i

		var x = cos(theta) * radius
		var z = sin(theta) * radius

		points.append(Vector3(x, y, z) * sphere_radius)
	
	return points
