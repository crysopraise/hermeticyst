extends Area

export var speed = 5

func _process(delta):
	translate(Vector3.BACK * speed * delta)

func _on_kill_timeout():
	queue_free()

