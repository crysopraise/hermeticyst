extends "res://scripts/enemies/enemy.gd"

# Constants
var MAX_ANGLE = deg2rad(30)


# Nodes
var polyp_bullet


# Variables
var player_out_of_range = true
var check_range = randi() % 2

func _ready():
	polyp_bullet = preload('res://scenes/enemies/attacks/polyp_bullet.tscn').instance().init()
	var level = get_tree().current_scene
	BulletManager.add_child(polyp_bullet)
	connect('tree_exited', self, 'on_exit')

func on_exit():
	polyp_bullet.queue_free()

func active_state(delta):
	if check_range == 0:
		player_out_of_range = is_player_out_of_range()
	check_range = (check_range + 1) % 2

	if $Timer.is_stopped() and !player_out_of_range:
		is_attacking = true

func attack_state(delta):
	if polyp_bullet.is_dead:
		polyp_bullet.fire({
			'position': $SpawnPoint.global_transform.origin,
			'direction': -global_transform.basis.z
		})

func _on_timeout():
	._on_timeout()
	if is_attacking:
		$Timer.start(COOLDOWN_TIME)

func is_player_out_of_range():
	return transform.origin.distance_squared_to(player.transform.origin) \
			> ARGRO_RANGE_SQUARED \
			or get_world().direct_space_state.intersect_ray(
				transform.origin,
				player.transform.origin,
				[],
				1
			)

