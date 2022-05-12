# Edit Placeholders.tscn in editor, then run this script to generate resource file
# NOTE: do NOT change the 'Background' original scene !! It is a part of the game
tool
extends EditorScript


func _run() -> void:
	var scene: Node2D = load("res://Temp/Placeholders.tscn").instance()
	var curve: Curve2D = load("res://Game/Resources/MovePath2D.tres")
	var positions: PoolVector2Array
	var rotations: PoolRealArray
	var groups := []
	var index := 0
	
	for group_node in scene.get_node("Placeholders").get_children():
		var count = group_node.get_child_count()
		var group_position = group_node.position
		var _group_data: Dictionary = parse_name(group_node.name)
		_group_data.StartIndex = index
		_group_data.Size = count
		_group_data.Offset = curve.get_closest_offset(group_position)
		groups.append(_group_data)
		for placeholder in group_node.get_children():
			positions.append(group_position + placeholder.position)
			rotations.append(placeholder.rotation)
		index += count
	groups.sort_custom(self, "_sort_by_offset")
	
	var resource = Places.new()
	resource.positions = positions
	resource.rotations = rotations
	resource.groups = groups
	print(ResourceSaver.save("res://Game/Resources/Places.tres", resource))
	scene.free()

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
	var _app_max = (name.substr(_app_max_pos, _pop_min_pos - _app_max_pos)) as int
	var _app_min = (name.substr(_app_min_pos, _app_max_pos - _app_min_pos)) as int if _app_max_len != -1 else _app_max
	var _pop_max = (name.substr(_pop_max_pos, _group_pos - _pop_max_pos)) as int
	var _pop_min = (name.substr(_pop_min_pos, _pop_max_pos - _pop_min_pos)) as int if _pop_max_len != -1 else _pop_max
	
	return {Name = name, Index = _group, AppearanceMin = _app_min, AppearanceMax = _app_max, PopulationMin = _pop_min, PopulationMax = _pop_max}

func _sort_by_offset(a: Dictionary, b: Dictionary) -> bool:
	return a.Offset > b.Offset
