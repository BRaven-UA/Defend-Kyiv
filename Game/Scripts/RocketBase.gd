# utility class to bypass GODOT cyclic dependency issue
# contains all public fields and methods
class_name RocketBase
extends Area2D

const SPEED: int = 400
const TANG_SPEED: float = 0.9
const SPREAD: float = 0.08 # 2D rocket spread in percent (0-1)

var is_free: bool = true


func get_height() -> float:
	return 0.0

func activate(shoot: Node2D, pos: Vector3, dir: Vector3, tar: Node2D) -> void:
	pass

func deactivate() -> void:
	pass

func reset() -> void:
	pass

func detonation() -> void:
	pass
