extends Area

export var SPEED = 5
export var SIZE = 1
export var KILL_TIME = 10

var move_forward
var speed

func init(kill_time = KILL_TIME, init_speed = SPEED, init_move_forward = true, size = SIZE):
	$CollisionShape.scale *= size
	$MeshInstance.scale *= size
	$KillTimer.start(kill_time)
	speed = init_speed
	move_forward = init_move_forward
	return self

func _physics_process(delta):
	move(delta)

func move(delta):
	translate((Vector3.FORWARD if move_forward else Vector3.BACK) * speed * delta)

func die():
	queue_free()

func _on_hit_player(_area):
	Global.on_player_die()

func _on_hit_environment(_body):
	queue_free()

