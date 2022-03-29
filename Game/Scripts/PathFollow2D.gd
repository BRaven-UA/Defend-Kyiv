extends PathFollow2D


func _enter_tree() -> void:
	Global.path_follow = self # register itself in global singleton
	get_parent().visible = true # the parent may be hidden in the editor due to Path2D performance issues

#func _process(delta: float) -> void:
#	# constantly move along the path
#	offset += delta * 100
	
