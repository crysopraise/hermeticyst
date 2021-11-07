extends Area

export var SPEED = 5
export var SIZE = 1
export var KILL_TIME = 10

var move_forward
var speed

func init(position, init_speed = SPEED, kill_time = KILL_TIME, init_move_forward = true, size = SIZE):
	translation = position
	$CollisionShape.scale *= size
	$MeshInstance.scale *= size
	$KillTimer.start(kill_time)
	speed = init_speed
	move_forward = init_move_forward
	return self

func _ready():
	var player = get_parent().get_node_or_null('Player')
	if player and translation.distance_squared_to(player.translation) < player.SAFE_DISTANCE_SQUARED:
		die()

func _physics_process(delta):
	move(delta)

func move(delta):
	translate((Vector3.FORWARD if move_forward else Vector3.BACK) * speed * delta)

func die():
	queue_free()

func _on_hit_player(area):
	# Collide with player bullet hitbox
	if area.collision_layer & 16:
		area.get_parent().die()

func _on_hit_environment(_body):
	queue_free()

