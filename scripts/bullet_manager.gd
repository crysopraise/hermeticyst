extends Node

export var POOL_SIZE = 200
export var DESTROYABLE_CHANCE = 0.3

var bullet_pools = {}

func create_pool(bullet_name, params = {}):
	if bullet_pools.has(bullet_name):
		bullet_pools[bullet_name].entities += 1
		if bullet_pools[bullet_name].pool.size() >= bullet_pools[bullet_name].entities * POOL_SIZE:
			return
	else:
		bullet_pools[bullet_name] = {
			'pool': [],
			'idx': 0,
			'entities': 1
		}
	
	for i in POOL_SIZE:
		params.is_destroyable = randf() < DESTROYABLE_CHANCE
		var bullet = load("res://scenes/enemies/attacks/" + bullet_name + ".tscn").instance().init(params)
		bullet_pools[bullet_name].pool.append(bullet)
		add_child(bullet)

func fire_bullet(bullet_name, params):
	var bullet_pool = bullet_pools[bullet_name]
	var bullet = bullet_pool.pool[bullet_pool.idx]
	bullet_pool.idx = wrapi(bullet_pool.idx + 1, 0, bullet_pool.pool.size() - 1)
	bullet.fire(params)
	return bullet

func reset_bullets():
	for bullet_pool in bullet_pools.values():
		for bullet in bullet_pool.pool:
			bullet.die()
		bullet_pool.idx = 0

func reset_pools():
	for bullet_pool in bullet_pools.values():
		bullet_pool.entities = 0
