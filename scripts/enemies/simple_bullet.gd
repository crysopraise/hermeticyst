extends Area

export var speed = 5
export var move_forward = false
export var size = 1

func _ready():
	$CollisionShape.scale *= size
	$MeshInstance.scale *= size

func _process(delta):
	translate((Vector3.FORWARD if move_forward else Vector3.BACK) * speed * delta)

func _on_kill_timeout():
	queue_free()

func _on_hit(body):
	if body.is_in_group('player'):
		body.die()

