extends Area

export var speed = 5
export var move_forward = false
export var size = 1

var base_wait = 0 # Set by enemy
var direction = Vector3.FORWARD
var changing_direction = false

func _ready():
	$CollisionShape.scale *= size
	$MeshInstance.scale *= size

func _process(delta):
	if not changing_direction:
		translate((Vector3.FORWARD if move_forward else Vector3.BACK) * speed * delta)

func _on_drift():
	#var x = 1 - randf()
	#var y = rand_range(0, 1 - x)
	#var z = 1 - x - y
	if not changing_direction:
		rotate_x(rand_range(0, TAU))
		rotate_y(rand_range(0, TAU))
		rotate_z(rand_range(0, TAU))
		changing_direction = true
		$DriftTimer.wait_time = base_wait - $DriftTimer.wait_time
		$DriftTimer.start()
	else:
		changing_direction = false

func _on_kill_timeout():
	queue_free()

