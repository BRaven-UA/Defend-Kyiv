extends Node

enum EXPLOSION {RocketExplosion, VehicleExplosion, AmmunitionExplosion, FuelExplosion, AerialExplosion}

var target_pool: Array
var rocket_pool: Array # object pool for rockets
var explosion_pool: Array # object pool for explosions
var explosion_indexes: Dictionary # keys are explosion names, values are list of pool indexes with that explosion instance
var crater_pool: Array # object pool for crater decals
var flying_text_pool: Array
var warning_sign_pool: Array


func get_target() -> Target:
	for target in target_pool:
		if not target.is_inside_tree():
			return target
	
	var new_target = Target.new()
	target_pool.append(new_target)
	return new_target

func get_rocket() -> RocketBase: # get reference to new rocket from the rocket pool
	for rocket in rocket_pool: # search for free rocket
		if rocket.is_free:
			return rocket
	
	# add new instance to the pool if there no free rockets left
	var new_rocket = Preloader.get_resource("Rocket").instance()
	rocket_pool.append(new_rocket)
	return new_rocket

func get_explosion(type: int) -> Explosion: # get reference to new explosion with given type from the explosion pool
	var _name = EXPLOSION.keys()[type]
	
	for index in explosion_indexes.get(_name, []): # list of indexes or empty list
		var explosion: Explosion = explosion_pool[index]
		if explosion.is_free:
#			Global.ground_layer.add_child(explosion)
			return explosion
	
	# add new instance to the pool if there no free explosions left
	var new_explosion = Preloader.get_resource(_name).instance()
	
	var index = explosion_pool.size()
	explosion_pool.append(new_explosion)
	Global.above_ground_layer.add_child(new_explosion)
	# store corresponding index
	var _indexes: Array = explosion_indexes.get(_name, []) # list of indexes or empty list
	_indexes.append(index) # add new index
	explosion_indexes[_name] = _indexes # store updated list
	
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

func get_flying_text() -> FlyingText:
	for flying_text in flying_text_pool:
		if not flying_text.is_inside_tree():
			return flying_text
	
	var new_flying_text = FlyingText.new()
	flying_text_pool.append(new_flying_text)
	return new_flying_text

func get_warning_sign() -> WarningSign:
	if Global.hud == null:
		return null
	
	for warning_sign in warning_sign_pool:
		if not warning_sign.visible:
			return warning_sign
	
	var new_warning_sign = Preloader.get_resource("WarningSign").instance()
	warning_sign_pool.append(new_warning_sign)
	Global.hud.warnings.add_child(new_warning_sign)
	return new_warning_sign
