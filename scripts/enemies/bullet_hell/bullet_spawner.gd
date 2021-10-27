extends Spatial

export var spawn_point_count = 20
export var radius = 4.0
export var rotation_speed = 2
export var rotate_cos = true
export var has_multiple_spawns = true
export var bullet_scn_file = "simple_bullet.tscn"
export var BULLET_SPEED = 5
export var BULLET_SIZE = 1
export var BULLET_KILL_TIME = 5
export var SHOOT_INTERVAL = 0.25
export var ATTACK_DURATION = 3
export var COOLDOWN_TIME = 5

var bullet_scn

onready var base_rotation = rotation
var time = 0
var is_shooting = false

func _ready():
	bullet_scn = load("res://scenes/enemies/bullet_hell/" + bullet_scn_file)
	if has_multiple_spawns:
		create_spawns()
	$ShootTimer.wait_time = SHOOT_INTERVAL
	$AttackTimer.wait_time = ATTACK_DURATION
	$CooldownTimer.wait_time = COOLDOWN_TIME

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
		var bullet = bullet_scn.instance().init(BULLET_KILL_TIME, BULLET_SPEED, false)
		get_tree().current_scene.add_child(bullet)
		bullet.transform.origin = s.global_transform.origin
		bullet.look_at(global_transform.origin, Vector3.LEFT)

func stop_attack():
	$ShootTimer.stop()
	# $CooldownTimer.start()
	is_shooting = false

func start_attack():
	# $AttackTimer.start()
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
