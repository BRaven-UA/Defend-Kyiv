extends Node

enum {NAME, FRAME, RARITY, EXPLOSION} # list of each enemy keys
const ENEMIES := [
	{NAME: "Tigr", FRAME: 0, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "2S7 Pion", FRAME: 1, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "9K37 Buk", FRAME: 2, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "BTR-80", FRAME: 3, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Black Eagle", FRAME: 4, RARITY: Global.RARITY.LEGENDARY, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Borisoglebsk-2", FRAME: 5, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Pantsir-S", FRAME: 6, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion}
]
const CHANCES := [0.0, 1.0, 0.33, 0.1, 0.05, 0.015] # spawn chances for none/common/uncommon/rare/epic/legendary enemies

var places: Places # reference to placeholders database
var enemy_prefab: PackedScene
var enemies: Array # list containing dictionaries with enemy data
var total_chance := 0.0 # total spawn chance for all enemies


func _ready() -> void:
	places = Preloader.get_resource("Places")
	enemy_prefab = Preloader.get_resource("Enemy")
	
#	# search for available enemy scenes
#	for name in Preloader.get_resource_list():
#		if name.begins_with("Vehicle_"):
#			var _enemy: PackedScene = Preloader.get_resource(name)
##			var _names = _enemy._bundled.names
##			for index in _names.size(): # FACEPALM: PoolArrays don't have any search methods
##				if _names[index] == "rarity":
##					var _chance: float = CHANCES[_enemy._bundled.variants[index]]
##					# add each enemy data to the list (key: reference to packed scene, value: spawn chance)
##					enemies.append({_enemy:_chance})
##					total_chance += _chance # increase total chance with each new enemy
##					break
#			var enemy: Enemy = _enemy.instance()
#			var _chance: float = CHANCES[enemy.rarity]
#			enemy.queue_free()
#			# add each enemy data to the list (key: reference to packed scene, value: spawn chance)
#			enemies.append({_enemy:_chance})
#			total_chance += _chance # increase total chance with each new enemy
	for enemy_data in ENEMIES:
		total_chance += CHANCES[enemy_data[RARITY]]
	
	for group_data in places.groups:
		spawn_enemy_group(group_data)
#	spawn_enemy_group(places.groups[4])
#	spawn_enemy_group(places.groups[3])
#	spawn_enemy_group(places.groups[2])

func spawn_enemy_group(group_data: Dictionary) -> void:
	assert(group_data)
	var appearance = _rand_range(group_data.AppearanceMin, group_data.AppearanceMax)
	if appearance <0.01:
		return
	
	var indexes := []
	indexes.resize(group_data.Size)
	for i in group_data.Size:
		indexes[i] = group_data.StartIndex + i
	
	var population = _rand_range(group_data.PopulationMin, group_data.PopulationMax)
	indexes.shuffle()
	indexes.resize(group_data.Size * population)
	
	for index in indexes:
		var enemy: Enemy = enemy_prefab.instance() # using Enemy class leads to cyclic dependency :(
		var enemy_data: Dictionary = get_random_enemy()
		enemy.init(enemy_data, places.positions[index], places.rotations[index])
		Global.ground_layer.add_child(enemy)

func _rand_range(_min: int, _max: int) -> float:
	return _min / 100.0 + (_max - _min) / 100.0 * randf()

func get_random_enemy() -> Dictionary:
	ENEMIES.shuffle()

	var cut_off = randf() * total_chance
	var current_chance := 0.0
	for enemy_data in ENEMIES:
		current_chance += CHANCES[enemy_data[RARITY]]
		if cut_off <= current_chance:
			return enemy_data
	
	assert(false)
	return {}
