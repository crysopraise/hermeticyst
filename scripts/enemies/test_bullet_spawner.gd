extends Spatial

signal attack_finished

export var SHOOT_INTERVAL = 0.75
export var BULLET_SPEED = 7.5
export var BULLET_KILL_TIME = 5
export var BULLET_NAME = "bullet"

var is_shooting = false

var PATTERN = []

var pattern_idx = 0
var last_axis = Vector3.UP

func _ready():
	BulletManager.create_pool(BULLET_NAME)

func spread_shot(bullet_count, spread, delay = 0, delay_inc = 0, z_rot = 0, x_rot = 0, y_rot = 0):
	var axis = global_transform.basis.y \
		.rotated(global_transform.basis.z, deg2rad(z_rot))
	last_axis = axis
	var fire_dir = (-global_transform.basis.z) \
		.rotated(global_transform.basis.x, deg2rad(x_rot)) \
		.rotated(global_transform.basis.y, deg2rad(y_rot)) \
		.rotated(axis, -deg2rad(spread / 2) + deg2rad(spread / bullet_count / 2))
	var i_delay = 0
	for i in range(bullet_count):
		BulletManager.fire_bullet(BULLET_NAME, {
				'position': global_transform.origin,
				'direction': fire_dir,
				'speed': BULLET_SPEED,
				'kill_time': BULLET_KILL_TIME,
				'delay': delay + i_delay})
		fire_dir = fire_dir.rotated(axis, deg2rad(spread / bullet_count))
		i_delay = i_delay + delay_inc

func shoot():
	var shot = PATTERN[pattern_idx]
	var step = shot.step
	var total_time = 0
	while shot.step == step:
		total_time += shot.args[2] + shot.args[0] * shot.args[3]
		self.callv(shot.type, shot.args)
		pattern_idx = (pattern_idx + 1) % PATTERN.size()
		shot = PATTERN[pattern_idx]
		
		# Prevent infinite loop
		if pattern_idx == 0:
			step = -1
	if total_time > 0:
		$ShootTimer.start(total_time)
	else:
		emit_signal('attack_finished')

func attack_end():
	emit_signal('attack_finished')
