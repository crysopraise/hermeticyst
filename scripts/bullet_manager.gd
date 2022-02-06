extends Node

export var POOL_SIZE = 200
export var DESTROYABLE_CHANCE = 0.3

var bullet_pools = {}

func create_pool(entity_id, bullet_name, pool_size = 20):
	if !bullet_pools.has(entity_id):
		bullet_pools[entity_id] = {
			'pool': [],
			'idx': 0,
		}
	
	for i in pool_size:
		var bullet = load("res://scenes/enemies/attacks/" + bullet_name + ".tscn").instance()
		bullet_pools[entity_id].pool.append(bullet)
		add_child(bullet)

func fire_bullet(entity_id, params):
	var bullet_pool = bullet_pools[entity_id]
	var bullet = bullet_pool.pool[bullet_pool.idx]
	bullet_pool.idx = wrapi(bullet_pool.idx + 1, 0, bullet_pool.pool.size() - 1)
	if params.get('delay', 0) > 0:
		bullet.delayed_fire(params, params.delay)
	else:
		bullet.fire(params)
	return bullet

func reset_bullets():
	for bullet_pool in bullet_pools.values():
		for bullet in bullet_pool.pool:
			bullet.die()
		bullet_pool.idx = 0

func reset_pools():
	bullet_pools.clear()
