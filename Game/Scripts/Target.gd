# helper class representing pseudo3D object
class_name Target
extends Node2D

const HEIGHT: float = 1.0


func rand_position(spread: float) -> void:
	position.x += (randf() - 0.5) * spread
	position.y += (randf() - 0.5) * spread
