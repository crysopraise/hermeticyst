extends KinematicBody

export var SPAWN_POINT_COUNT = 20
export var RADIUS = 4
export var rotate_cos = true

onready var bullet_scn = preload("res://scenes/enemies/tree_bullet.tscn")
onready var player = get_node("../Player")

onready var base_rotation = $Rotater.rotation
var is_shooting = false
var time = 0

func _ready():
	for p in get_spawn_points(SPAWN_POINT_COUNT, RADIUS):
		var spawn_point = Spatial.new()
		$Rotater.add_child(spawn_point)
		spawn_point.transform = Transform(Basis.IDENTITY, p)
	
	# Show points
	var im = ImmediateGeometry.new()
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS)
	im.set_color(Color(1,0,0))
	#set_normal(Vector3(0, 0, 1))
	#set_uv(Vector2(0, 0,))
	for s in $Rotater.get_children():
		im.add_vertex(s.transform.origin)
	
func _process(delta):
	if is_shooting:
		if rotate_cos:
			time += delta / 2
			$Rotater.rotation.y = base_rotation.y + cos(time)
			$Rotater.rotation.x = base_rotation.x + cos(time)
		else:
			var rot = delta / 2
			$Rotater.rotate_y(rot)
			$Rotater.rotate_x(rot)
	else:
		var target_rotation = transform.looking_at(player.transform.origin, Vector3.UP)
		transform = transform.interpolate_with(target_rotation, delta)

func _on_shoot():
	for s in $Rotater.get_children():
		var bullet = bullet_scn.instance()
		get_tree().root.add_child(bullet)
		bullet.transform.origin = s.global_transform.origin
		bullet.look_at(transform.origin, Vector3.LEFT)

func _on_attack_end():
	print('attack end')
	$ShootTimer.stop()
	$CooldownTimer.start()
	is_shooting = false

func _on_cooldown_end():
	print('cooldown end')
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

