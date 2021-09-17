extends Area

export var initial_speed = 5
export var homing_speed = 100

var is_targetting = false
var has_targeted = false

func _physics_process(delta):
	if not is_targetting:
		if has_targeted:
			translate(Vector3.FORWARD * homing_speed * delta)
		else:
			translate(Vector3.BACK * initial_speed * delta)

func _on_target():
	if not has_targeted:
		is_targetting = true
		has_targeted = true
		$TargetTimer.start()
	else:
		look_at(get_tree().current_scene.get_node("Player").transform.origin, Vector3.UP)
		is_targetting = false

func _on_bullet_hit(body):
	if body.is_in_group("player"):
		print('hit player')
	queue_free()

func _on_kill_timeout():
	queue_free()

