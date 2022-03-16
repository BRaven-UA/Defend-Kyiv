extends Sprite


func _process(delta: float) -> void:
	# correct the position based on the rotation of the path_follow node
	position = Vector2(-82, -52).rotated(-Global.path_follow.rotation)
