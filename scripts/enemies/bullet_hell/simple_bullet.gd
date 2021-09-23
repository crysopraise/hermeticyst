extends Area

export var speed = 5
export var move_forward = true
export var size = 1
export var kill_time = 10

func _ready():
	$CollisionShape.scale *= size
	$MeshInstance.scale *= size
	$KillTimer.wait_time = kill_time
	$KillTimer.start()

func _physics_process(delta):
	move(delta)

func move(delta):
	translate((Vector3.FORWARD if move_forward else Vector3.BACK) * speed * delta)

func die():
	queue_free()

func _on_hit_player(area):
	area.get_parent().die()

func _on_hit_environment(body):
	queue_free()

