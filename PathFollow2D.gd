extends PathFollow2D


func _process(delta: float) -> void:
	offset += delta * 200
