tool
extends EditorScript


func _run() -> void:
	print(get_scene().find_node("Player").global_rotation)
#	print(get_scene().find_node("Player").global_transform.get_rotation())
	
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
