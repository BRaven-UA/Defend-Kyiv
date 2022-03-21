extends PathFollow2D


func _enter_tree() -> void:
	Global.path_follow = self # register itself in global singleton

#func _process(delta: float) -> void:
#	# constantly move along the path
#	offset += delta * 100
	
