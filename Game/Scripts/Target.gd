# helper class representing pseudo3D object
class_name Target
extends Node2D

const HEIGHT: float = 1.0


func activate(pos: Vector2, spread := 0.0) -> void:
	if spread:
		pos.x += (randf() - 0.5) * spread
		pos.y += (randf() - 0.5) * spread
	global_position = pos
	Global.ground_layer.add_child(self)

func deactivate() -> void:
	Global.ground_layer.remove_child(self)
