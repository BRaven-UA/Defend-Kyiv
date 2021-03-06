extends Node

enum {NAME, FRAME, RARITY, EXPLOSION, ANTIAIRCRAFT, SPAWNED, DESTROYED} # list of each enemy keys
enum {AA_NONE, AA_ROCKETS, AA_CANNON, AA_BOTH} # Anti Aircraft systems
const ENEMIES := [
	{NAME: "Tigr", FRAME: 0, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "2S7 Pion", FRAME: 1, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "9K37 Buk", FRAME: 2, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion, ANTIAIRCRAFT: AA_ROCKETS},
	{NAME: "BTR-80", FRAME: 3, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Black Eagle", FRAME: 4, RARITY: Global.RARITY.LEGENDARY, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Borisoglebsk-2", FRAME: 5, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Pantsir-S", FRAME: 6, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion, ANTIAIRCRAFT: AA_BOTH},
	{NAME: "2S19 Msta", FRAME: 7, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "Ural (fuel)", FRAME: 8, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.FuelExplosion},
	{NAME: "Kamaz", FRAME: 9, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "T-72", FRAME: 10, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "ZSU-23-4 Shilka", FRAME: 11, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion, ANTIAIRCRAFT: AA_CANNON},
	{NAME: "Typhoon-K", FRAME: 12, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "9K330 Tor", FRAME: 13, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion, ANTIAIRCRAFT: AA_ROCKETS},
	{NAME: "TOS-1A Solntsepyok", FRAME: 14, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "Iveco LMV", FRAME: 15, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "UR-77 Meteorit", FRAME: 16, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion, ANTIAIRCRAFT: AA_CANNON}
]
const CHANCES := [0.0, 1.0, 0.33, 0.1, 0.05, 0.015] # spawn chances for none/common/uncommon/rare/epic/legendary enemies
const AA_ROCKET_DELAY := 7.0
const AA_CANNON_DELAY := 3.0
const AA_CANNON_PARTICLES := 4

#var enemies: Array # list containing dictionaries with enemy data
var total_chance := 0.0 # total spawn chance for all enemies


#func _ready() -> void:
#	spawn_enemy(ENEMIES[3], Vector2(63310, -51262), 0)
	
#	for group_data in Global.game.places.groups:
#		spawn_enemy_group(group_data)
	
#	spawn_enemy_group(Global.game.places.groups[4])
#	spawn_enemy_group(Global.game.places.groups[3])
#	spawn_enemy_group(Global.game.places.groups[2])

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
		var enemy_data: Dictionary = get_random_enemy()
		enemy_data[SPAWNED] += 1
		spawn_enemy(enemy_data, Global.game.places.positions[index], Global.game.places.rotations[index])

func spawn_enemy(data: Dictionary, pos := Vector2.ZERO, rot := 0.0) -> void:
	var enemy: Enemy = PoolManager.get_aa_enemy() if data.get(ANTIAIRCRAFT) else PoolManager.get_enemy()
	if Global.game.path_follow:
		enemy.set_meta("Offset", Global.pos_to_offset(pos))
	if Global.game.ground_layer:
		Global.game.ground_layer.add_child(enemy, true)
	enemy.call_deferred("init", data, pos, rot)

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

func clear_statistics() -> void:
	total_chance = 0
	for enemy_data in ENEMIES:
		enemy_data[SPAWNED] = 0
		enemy_data[DESTROYED] = 0
		total_chance += CHANCES[enemy_data[RARITY]]

func _rand_range(_min: int, _max: int) -> float:
	return (_min + (_max - _min) * randf())/ 100.0
