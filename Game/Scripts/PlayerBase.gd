# utility class to bypass GODOT cyclic dependency issue
# contains all public fields and methods
class_name PlayerBase
extends Area2D

signal ammo_changed(value)

const HEIGHT: float = 500.0 # player's height above the ground
const PLAYER_SPEED: int = 100
const FULL_ACCELERATION: float = 3.0 # move modifier for keyboard input
const CROSSAIR_DISTANCE: float = 600.0 # distance to the crossair when player is centered
const ROCKET_COOLDOWN: float = 0.15 # rocket fire delay
const MAX_ROCKETS: int = 32 # max amount of rockets that player can carry

var velocity: Vector2 # player local velocity per second
var rockets_amount: int = MAX_ROCKETS # available rockets
var rocket_consumption: int = 1 # for debug purposes


func get_height() -> float:
	return HEIGHT

func hit_by_rocket() -> void:
	pass
