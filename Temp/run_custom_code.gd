tool
extends EditorScript

func _run() -> void:
	var current_crater := 1
	for i in 100:
		print(current_crater)
		current_crater = current_crater % 16 + 1

func k():
#	var pos = Vector2(100, 100)
	var node = get_scene().find_node("GroundTexture")
	var rot = node.global_rotation
	var node_pos = node.global_position.rotated(-rot)
	var pos = get_scene().find_node("OffscreenPuller").global_position.rotated(-rot)
	var screen_size = node.get_viewport_rect().size
	var screen_origin = node_pos - screen_size / 2.0
	var shader_pos = (pos - screen_origin) / screen_size
	print(shader_pos)
#	var node = get_scene().find_node("GroundTexture")
#	var node_pos = node.global_position
#	var pos = get_scene().find_node("OffscreenPuller").global_position
#	var screen_size = node.get_viewport_rect().size
#	var screen_origin = node_pos - screen_size.rotated(node.global_rotation) / 2.0
#	var shader_pos = (pos - screen_origin).rotated(-node.global_rotation) / screen_size
#	print(shader_pos)

func j():
	var c = Config.new()
	c.bri = 1.1
	print(c.get_property_list())
	
	var f = File.new()

	print(f.open_encrypted_with_pass("user://DefendKyiv.save", File.WRITE, Global.PASSWORD))
	var str1 = var2str(c)
	printt(str1)
	f.store_string(str1)
	f.close()

	yield(get_scene().get_tree().create_timer(.5), "timeout")
	
	print(f.open_encrypted_with_pass("user://DefendKyiv.save", File.READ, Global.PASSWORD))
	var str2 = f.get_as_text()
	f.close()
	var b: Config = str2var(str2)
#	printt(str2)
	print(b.bri)
#	print(b.get_property_list())


func i():
	var atlas_width = 5
	var texture_size = Vector2(154, 120)
	for i in 10:
		var index = i
		var row = index / atlas_width
		var column = index % atlas_width
		var texture_position = Vector2(column, row) * texture_size
		printt(i, texture_position)
#		printt(i, column)

func h():
	var arr = []
	arr.resize(100000)
	var time = OS.get_ticks_usec()
	arr.resize(arr.size() - 1)
#	arr.remove(arr.size() - 1)
	print(OS.get_ticks_usec() - time)
	

func g():
	var curve: Curve2D = load("res://Game/Resources/MovePath2D.tres")
	print(curve.get_closest_offset(Vector2(65487+20, -50655.7-20)))
#	print(curve.interpolate_baked(113572, true))

func f():
	var scene = get_scene()
	var player: Node2D = scene.find_node("Player")
#	printt(player.position, player.global_position)
#	printt(rad2deg(player.rotation), rad2deg(player.global_rotation))
	var velocity = Vector2(0, -10)
#	print(player.to_global(velocity))
#	print(player.transform.xform_inv(velocity))
	print(velocity.rotated(player.global_rotation))
	
func _get_all_nodes(root: Node, list = []):
	for node in root.get_children():
		if node.get_class() == "CanvasItemEditorViewport":
			node.visible = !node.visible
		list.append(node)
		_get_all_nodes(node, list)
	return list
	
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

