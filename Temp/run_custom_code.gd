tool
extends EditorScript
const COLOR_NONE = Color.transparent
const COLOR_COMMON = Color.white
const COLOR_UNCOMMON = Color.green
const COLOR_RARE = Color.dodgerblue
const COLOR_EPIC = Color.blueviolet
const COLOR_LEGENDARY = Color.orange
enum RARITY {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const COLOR = [COLOR_NONE, COLOR_COMMON, COLOR_UNCOMMON, COLOR_RARE, COLOR_EPIC, COLOR_LEGENDARY]
enum EXPLOSION {VehicleExplosion, AmmunitionExplosion}


func _run() -> void:
	var f: float = 0.0
	print(f + ".1" as float)

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


