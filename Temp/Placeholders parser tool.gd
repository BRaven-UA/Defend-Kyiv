tool
extends EditorScript


func _run() -> void:
	var scene: Node2D = load("res://Temp/Placeholders.tscn").instance()
	var positions: PoolVector2Array
	var rotations: PoolRealArray
	var groups = []
	var index := 0
	
	for group_node in scene.get_children():
		var count = group_node.get_child_count()
		groups.append({Name = group_node.name, StartIndex = index, Size = index + count})
		var group_position = group_node.position
		for placeholder in group_node.get_children():
			positions.append(group_position + placeholder.position)
			rotations.append(placeholder.rotation)
		index += count
	
	var resource = load("res://Game/Scripts/Places.gd").new()
	resource.positions = positions
	resource.rotations = rotations
	resource.groups = groups
	print(ResourceSaver.save("res://Game/Places.tres", resource))
