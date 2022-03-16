extends Node

var explosion_pool: Array
var indexes: Dictionary # keys are explosion names, values are list of pool indexes with that explosion instance


func activate(_name: String, pos: Vector2): # activate an explosion with given name and global position
	var explosion: AnimatedSprite = get_explosion(_name)
	explosion.global_position = pos
	explosion.global_rotation = Global.player.global_rotation
	explosion.flip_h = (randi() % 2) as bool # add some randomness
	explosion.frame = 0
	explosion.play()
	explosion.get_node("Sound").play()

func get_explosion(_name: String) -> AnimatedSprite: # get reference to new explosion with given name from the explosion pool
	for index in indexes.get(_name, []): # list of indexes or empty list
		if not explosion_pool[index].is_playing(): # check for idle
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
