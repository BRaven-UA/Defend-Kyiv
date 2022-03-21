extends Node

var explosion_pool: Array # object pool for explosions
var indexes: Dictionary # keys are explosion names, values are list of pool indexes with that explosion instance
var crater_pool: Array # object pool for crater decals


func get_explosion(_name: String) -> Explosion: # get reference to new explosion with given name from the explosion pool
	for index in indexes.get(_name, []): # list of indexes or empty list
		if explosion_pool[index].is_free:
			return explosion_pool[index]
	
	# add new instance to the pool if there no free explosions left
	var new_explosion = Preloader.get_resource(_name).instance()
	
	var index = explosion_pool.size()
	explosion_pool.append(new_explosion)
	Global.ground_layer.add_child(new_explosion)
	# store corresponding index
	var _indexes: Array = indexes.get(_name, []) # list of indexes or empty list
	_indexes.append(index) # add new index
	indexes[_name] = _indexes # store updated list
	
	return new_explosion


func get_crater() -> Sprite:
	var distance = Global.viewport_size.length() * 2 # guaranteed offscreen distance
	for crater in crater_pool: # search for free crater
		if (crater.global_position - Global.player.global_position).length() > distance: # far enough
			return crater
	
	# add new instance to the pool if there no free craterss left
	var new_crater = Preloader.get_resource("Crater").instance()
	crater_pool.append(new_crater)
	Global.ground_layer.add_child(new_crater)
	return new_crater
