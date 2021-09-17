extends KinematicBody

export var SPAWN_POINT_COUNT = 20
export var RADIUS = 4
export var TIMER_DELAY = 0.35

onready var bullet_scn = preload("res://scenes/enemies/drift_bullet.tscn")
onready var player = get_node("../Player")

var is_shooting = false
var rounds_shot = 0

func _ready():
	for p in get_spawn_points(SPAWN_POINT_COUNT, RADIUS):
		var spawn_point = Spatial.new()
		$Rotater.add_child(spawn_point)
		spawn_point.transform = Transform(Basis.IDENTITY, p)

func _process(delta):
	if is_shooting:
		pass
	else:
		var target_rotation = transform.looking_at(player.transform.origin, Vector3.UP)
		transform = transform.interpolate_with(target_rotation, delta)

func _on_shoot():
	for s in $Rotater.get_children():
		var bullet = bullet_scn.instance()
		get_tree().root.add_child(bullet)
		bullet.transform.origin = s.global_transform.origin
		bullet.look_at(transform.origin, Vector3.LEFT)
		bullet.base_wait = $AttackTimer.wait_time + 1
		var drift_timer = bullet.get_node("DriftTimer") 
		drift_timer.wait_time = max(
			bullet.base_wait - (1 + (rounds_shot * TIMER_DELAY)),
			TIMER_DELAY)
		drift_timer.start()
	rounds_shot += 1

func _on_attack_end():
	$ShootTimer.stop()
	$CooldownTimer.start()
	is_shooting = false
	rounds_shot = 0

func _on_cooldown_end():
	$AttackTimer.start()
	$ShootTimer.start()
	is_shooting = true

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

