extends 'res://scripts/enemies/melee_enemy.gd'

func active_state(delta):
	DebugOutput.add_output(animation_player.current_animation + ' ' + str(animation_player.is_playing()))
	var target_velocity = -transform.basis.z * SPEED
	target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED)
	velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	velocity = move_and_slide(velocity)

	var distance_to_player = translation.distance_to(player.translation)
	if distance_to_player < ATTACK_DISTANCE:
		start_attack()

func start_attack():
	if $DetonateTimer.is_stopped():
		print('start attack')
		$DetonateTimer.start(ATTACK_TIME)
		$Light.light_color = Color(1,0,0,1)
		var anim_speed = animation_player.get_animation(ANIM_PREFIX + '_detonate').length / ATTACK_TIME
		animation_player.play(ANIM_PREFIX + '_detonate', 0.1, anim_speed)

func attack():
	enemy_attack = attack_scn.instance()
	enemy_attack.translation = translation
	enemy_attack.get_node('CollisionShape').shape.radius = ATTACK_DISTANCE
	var mesh = enemy_attack.get_node('MeshInstance').mesh
	mesh.radius = ATTACK_DISTANCE
	mesh.height = ATTACK_DISTANCE * 2
	get_tree().current_scene.add_child(enemy_attack)
	queue_free()
	emit_signal("enemy_die")

func detonate():
	attack()

func is_colliding_with_attack():
	return false

func die(is_beam = false):
	start_attack()

