extends "res://scripts/enemies/bullet_hell/bullet_spawner.gd"

export var TIMER_DELAY = 0.35

var rounds_shot = 0

func shoot_state(delta):
	pass

func _on_shoot():
	for s in $SpawnContainer.get_children():
		var bullet = fire_bullet(s.global_transform.origin, s.global_transform.origin.direction_to(global_transform.origin))
#		var bullet = bullet_scn.instance().init(s.global_transform.origin)
#		get_tree().current_scene.add_child(bullet)
#		bullet.move_forward = false
#		bullet.look_at(global_transform.origin, Vector3.LEFT)
		bullet.base_wait = $AttackTimer.wait_time + 1
		var drift_timer = bullet.get_node("DriftTimer") 
		drift_timer.wait_time = max(
			bullet.base_wait - (1 + (rounds_shot * TIMER_DELAY)),
			TIMER_DELAY)
		drift_timer.start()
	rounds_shot += 1

func stop_attack():
	.stop_attack()
	rounds_shot = 0

