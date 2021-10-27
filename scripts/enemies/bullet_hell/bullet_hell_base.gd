extends "res://scripts/enemies/enemy_base.gd"

# Nodes
onready var bullet_spawner = $BulletSpawner

func active_state(delta):
	# On first run, start timing and switch to attack state
	if $Timer.is_stopped():
		_on_timeout()
	face_target(TURN_SPEED, delta)

func attack_state(delta):
	if !$BulletSpawner.is_shooting:
		$BulletSpawner.start_attack()

func _on_timeout():
	._on_timeout()
	if is_attacking:
		is_attacking = false
		$BulletSpawner.stop_attack()
		$Timer.start(COOLDOWN_TIME)
	else:
		is_attacking = true
		$Timer.start(ATTACK_TIME)

