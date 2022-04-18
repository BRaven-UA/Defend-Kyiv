tool
extends EditorScript
enum {NAME, FRAME, RARITY, EXPLOSION} 

func _run() -> void:
	print({NAME: "Tigr", FRAME: 0, RARITY: Global.RARITY.COMMON, EXPLOSION: PoolManager.EXPLOSION.VehicleExplosion})

func f():
	var scene: Node2D = get_scene()
	var curve: Curve2D = scene.get_node("Pos").curve
	print(curve._data["points"][5])
	
func b():
	var pos = Vector2(100, -100)
	var dest = Vector2(200, -50)
	print(pos.distance_to(dest))
	print(pos.move_toward(dest, 111))

func a():
	var speed = 100
	var position = Vector3(0, -500, 0)
	var destination = Vector3(-250, 0, -250)
	var input = Vector2(-1, -1)
	var angle = 0
	var direction = Vector3(input.x, 0, input.y).rotated(Vector3.RIGHT, angle)
	var velocity = direction * speed
	var _dir = position.direction_to(destination)
	
	for i in 10:
		print(velocity.linear_interpolate(_dir * speed, i / 10.0))

func c():
	var path: Curve2D = load("res://Game/MovePath2D.tres")
	print(path.get_point_count())
	
func d():
	var pool = []
	var idx = {}
	print(idx)
	var l = idx.get("dd", [])
	l.append(0)
	idx["dd"] = l
	print(idx)

func e():
	for direction in [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.ONE, Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)]:
		printt(direction, (Vector3(direction.x * direction.y, direction.y, 2.0 - abs(direction.y)) * 0.5).normalized())

func parse_name(name: String) -> Dictionary:
	assert(name)
	
	var _group_pos = name.find("G") + 1
	var _app_min_pos = name.find("A") + 1
	var _app_max_len = name.substr(_app_min_pos, 3).find("-")
	var _app_max_pos = _app_min_pos + _app_max_len + 1
	var _pop_min_pos = name.find("P") + 1
	var _pop_max_len = name.substr(_pop_min_pos, 3).find("-")
	var _pop_max_pos = _pop_min_pos + _pop_max_len + 1
	
	var _group = (name.substr(_group_pos)) as int
	var _app_max = (name.substr(_app_max_pos, _pop_min_pos - _app_max_pos)) as float
	var _app_min = (name.substr(_app_min_pos, _app_max_pos - _app_min_pos)) as float if _app_max_len != -1 else _app_max
	var _pop_max = (name.substr(_pop_max_pos, _group_pos - _pop_max_pos)) as float
	var _pop_min = (name.substr(_pop_min_pos, _pop_max_pos - _pop_min_pos)) as float if _pop_max_len != -1 else _pop_max
	
	return {Group = _group, AppearanceMin = _app_min, AppearanceMax = _app_max, PopulationMin = _pop_min, PopulationMax = _pop_max}

func _rand_range(_min: int, _max: int) -> float:
	return _min / 100.0 + (_max - _min) / 100.0 * randf()

