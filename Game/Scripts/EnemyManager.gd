extends Node

enum {NAME, FRAME, RARITY, EXPLOSION, ANTIAIRCRAFT} # list of each enemy keys
enum {AA_NONE, AA_ROCKETS, AA_CANNON, AA_BOTH} # Anti Aircraft systems
const ENEMIES := [
	{NAME: "Tigr", FRAME: 0, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "2S7 Pion", FRAME: 1, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "9K37 Buk", FRAME: 2, RARITY: Global.RARITY.EPIC, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion, ANTIAIRCRAFT: AA_ROCKETS},
	{NAME: "BTR-80", FRAME: 3, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Black Eagle", FRAME: 4, RARITY: Global.RARITY.LEGENDARY, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Borisoglebsk-2", FRAME: 5, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "Pantsir-S", FRAME: 6, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion, ANTIAIRCRAFT: AA_BOTH},
	{NAME: "2S19 Msta", FRAME: 7, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "Ural (fuel)", FRAME: 8, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.FuelExplosion},
	{NAME: "Kamaz", FRAME: 9, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion},
	{NAME: "T-72", FRAME: 10, RARITY: Global.RARITY.UNCOMMON, EXPLOSION: PoolManager.EXPLOSION.AmmunitionExplosion},
	{NAME: "ZSU-23-4 Shilka", FRAME: 11, RARITY: Global.RARITY.RARE, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion, ANTIAIRCRAFT: AA_CANNON}
]
const CHANCES := [0.0, 1.0, 0.33, 0.1, 0.05, 0.015] # spawn chances for none/common/uncommon/rare/epic/legendary enemies
const AA_ROCKET_DELAY := 7.0
const AA_CANNON_DELAY := 3.0

var places: Places # reference to placeholders database
var enemy_prefab: PackedScene
var aa_enemy_prefab: PackedScene
var enemies: Array # list containing dictionaries with enemy data
var total_chance := 0.0 # total spawn chance for all enemies


func _ready() -> void:
	places = Preloader.get_resource("Places")
	enemy_prefab = Preloader.get_resource("Enemy")
	aa_enemy_prefab = Preloader.get_resource("AntiAircraftEnemy")
	
	for enemy_data in ENEMIES:
		total_chance += CHANCES[enemy_data[RARITY]]
	
	spawn_enemy(ENEMIES[2], Vector2(66016, -50509), 73)
#	spawn_enemy(ENEMIES[2], Vector2(66944, -48930), 0)
#	spawn_enemy(ENEMIES[2], Vector2(66887, -51707), 0)
#	spawn_enemy(ENEMIES[2], Vector2(68640, -50055), 0)
	
#	for group_data in places.groups:
#		spawn_enemy_group(group_data)
	
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
		var enemy_data: Dictionary = get_random_enemy()
		spawn_enemy(enemy_data, places.positions[index], places.rotations[index])

func spawn_enemy(data: Dictionary, pos := Vector2.ZERO, rot := 0.0) -> void:
	var enemy: Enemy = aa_enemy_prefab.instance() if data.get(ANTIAIRCRAFT) else enemy_prefab.instance()
	enemy.init(data, pos, rot)
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
