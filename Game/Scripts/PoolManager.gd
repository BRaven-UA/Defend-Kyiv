extends Node

const REUSABLE := "Reusable" # name of the node group for nodes that can be reused
enum EXPLOSION {RocketExplosion, VehicleExplosion, AmmunitionExplosion, FuelExplosion, AerialExplosion}

var enemy_pool: Array
var aa_enemy_pool: Array # antiaircraft
var target_pool: Array
var projectiles_pool: Array
var projectile_fire_pool: Array
var projectile_hit_pool: Array
var rocket_pool: Array # object pool for rockets
var explosion_pool: Array # object pool for explosions
var explosion_indexes: Dictionary # keys are explosion names, values are list of pool indexes with that explosion instance
var crater_pool: Array # object pool for crater decals
var preview_pool: Array
var flying_text_pool: Array
var warning_sign_pool: Array


func get_enemy() -> Enemy:
	for enemy in enemy_pool:
		if not enemy.is_inside_tree():
			return enemy
	
	var new_enemy = Preloader.get_resource("Enemy").instance()
	new_enemy.add_to_group(REUSABLE)
	enemy_pool.append(new_enemy)
	return new_enemy

func get_aa_enemy() -> AAEnemy:
	for aa_enemy in aa_enemy_pool:
		if not aa_enemy.is_inside_tree():
			return aa_enemy
	
	var new_aa_enemy = Preloader.get_resource("AntiAircraftEnemy").instance()
	new_aa_enemy.add_to_group(REUSABLE)
	aa_enemy_pool.append(new_aa_enemy)
	return new_aa_enemy

func get_target() -> Target:
	for target in target_pool:
		if not target.is_inside_tree():
			return target
	
	var new_target = Target.new()
	new_target.add_to_group(REUSABLE)
	target_pool.append(new_target)
	return new_target

func get_projectiles() -> Projectiles:
	for projectiles in projectiles_pool:
		if not projectiles.is_inside_tree():
			return projectiles
	
	var new_projectiles = Preloader.get_resource("Projectile").instance()
	new_projectiles.add_to_group(REUSABLE)
	projectiles_pool.append(new_projectiles)
	return new_projectiles

func get_projectile_fire() -> AudioStreamPlayer2D:
	for projectile_fire in projectile_fire_pool:
		if not projectile_fire.is_inside_tree():
			return projectile_fire
	
	var new_projectile_fire = Preloader.get_resource("ProjectileFire").instance()
	new_projectile_fire.add_to_group(REUSABLE)
	new_projectile_fire.connect("finished", self, "_remove_me", [new_projectile_fire])
	projectile_fire_pool.append(new_projectile_fire)
	return new_projectile_fire

func get_projectile_hit() -> AudioStreamPlayer:
	for projectile_hit in projectile_hit_pool:
		if not projectile_hit.is_inside_tree():
			return projectile_hit
	
	var new_projectile_hit = Preloader.get_resource("ProjectileHit").instance()
	new_projectile_hit.add_to_group(REUSABLE)
	new_projectile_hit.connect("finished", self, "_remove_me", [new_projectile_hit])
	projectile_hit_pool.append(new_projectile_hit)
	return new_projectile_hit

func get_rocket() -> RocketBase: # get reference to new rocket from the rocket pool
	for rocket in rocket_pool: # search for free rocket
#		if rocket.is_free:
		if not rocket.is_inside_tree():
			return rocket
	
	# add new instance to the pool if there no free rockets left
	var new_rocket = Preloader.get_resource("Rocket").instance()
	new_rocket.add_to_group(REUSABLE)
	rocket_pool.append(new_rocket)
	return new_rocket

func get_explosion(type: int) -> Explosion: # get reference to new explosion with given type from the explosion pool
	var _name = EXPLOSION.keys()[type]
	
	for index in explosion_indexes.get(_name, []): # list of indexes or empty list
		var explosion: Explosion = explosion_pool[index]
		if not explosion.is_inside_tree():
#		if explosion.is_free:
#			Global.ground_layer.add_child(explosion)
			return explosion
	
	# add new instance to the pool if there no free explosions left
	var new_explosion = Preloader.get_resource(_name).instance()
	new_explosion.add_to_group(REUSABLE)
	var index = explosion_pool.size()
	explosion_pool.append(new_explosion)
	# store corresponding index
	var _indexes: Array = explosion_indexes.get(_name, []) # list of indexes or empty list
	_indexes.append(index) # add new index
	explosion_indexes[_name] = _indexes # store updated list
	
	return new_explosion

func get_crater() -> Sprite:
#	var distance = Global.viewport_size.length() * 2 # guaranteed offscreen distance
	for crater in crater_pool: # search for free crater
		if not crater.is_inside_tree():
#		if (crater.global_position - Global.game.player.global_position).length() > distance: # far enough
			return crater
	
	# add new instance to the pool if there no free craterss left
	var new_crater = Preloader.get_resource("Crater").instance()
	new_crater.add_to_group(REUSABLE)
	crater_pool.append(new_crater)
	return new_crater

func get_preview() -> Preview:
# TODO: joint2D stops work after readded to the scene tree

#	for preview in preview_pool:
#		if not preview.is_inside_tree():
#			return preview
	
	var new_preview = Preloader.get_resource("Preview").instance()
#	new_preview.add_to_group(REUSABLE)
#	preview_pool.append(new_preview)
	return new_preview

func get_flying_text() -> FlyingText:
	for flying_text in flying_text_pool:
		if not flying_text.is_inside_tree():
			return flying_text
	
	var new_flying_text = FlyingText.new()
	new_flying_text.add_to_group(REUSABLE)
	flying_text_pool.append(new_flying_text)
	return new_flying_text

func get_warning_sign() -> WarningSign:
	for warning_sign in warning_sign_pool:
		if not warning_sign.is_inside_tree():
#		if not warning_sign.visible:
			return warning_sign
	
	var new_warning_sign = Preloader.get_resource("WarningSign").instance()
	new_warning_sign.add_to_group(REUSABLE)
	warning_sign_pool.append(new_warning_sign)
	return new_warning_sign

func return_all_reusable() -> void:
	for node in get_tree().get_nodes_in_group(REUSABLE):
		_remove_me(node)

func _remove_me(node) -> void:
	node.get_parent().remove_child(node)
