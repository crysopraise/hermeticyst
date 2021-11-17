extends Spatial

# Constants
export var spawn_point_count = 20
export var radius = 4.0
export var rotation_speed = 2
export var rotate_cos = true
export var has_multiple_spawns = true
export var bullet_scn_file = "bullet.tscn"
export var BULLET_SPEED = 5
export var BULLET_SIZE = 1
export var BULLET_KILL_TIME = 5
export var BULLET_MOVE_FORWARD = false
export var SHOOT_INTERVAL = 0.25
export var ATTACK_DURATION = 3
export var COOLDOWN_TIME = 5
export var DESTROYABLE_CHANCE = 0.4
export var POOL_SIZE = 200

# Scenes
#var bullet_scn = preload("res://scenes/enemies/attacks/bullet.tscn")
var bullet_scn

# Variables
onready var base_rotation = rotation
var time = 0
var is_shooting = false
var bullet_pool = []
var pool_idx = 0

func _ready():
	bullet_scn = load("res://scenes/enemies/attacks/" + bullet_scn_file)
	if has_multiple_spawns:
		create_spawns()
	$ShootTimer.wait_time = SHOOT_INTERVAL
	$AttackTimer.wait_time = ATTACK_DURATION
	$CooldownTimer.wait_time = COOLDOWN_TIME
	for i in POOL_SIZE:
		var is_destroyable = randf() < DESTROYABLE_CHANCE
		var bullet = bullet_scn.instance().init({
			'position': global_transform.origin,
			'speed': BULLET_SPEED,
			'kill_time': BULLET_KILL_TIME,
			'move_forward': false,
			'is_destroyable': is_destroyable})
		bullet_pool.append(bullet)
		get_tree().current_scene.call_deferred("add_child", bullet)


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
		fire_bullet(s.global_transform.origin,  s.global_transform.origin.direction_to(global_transform.origin))

func fire_bullet(position, direction):
	var bullet = bullet_pool[pool_idx]
	pool_idx = wrapi(pool_idx + 1, 0, POOL_SIZE - 1)
	bullet.fire(position, direction)
	return bullet

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
