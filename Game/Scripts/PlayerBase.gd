# utility class to bypass GODOT cyclic dependency issue
# contains all public fields and methods
class_name PlayerBase
extends Area2D

signal durability_changed(value)
signal ammo_changed(value)
signal flares_used(flares_array)
signal destroyed

const HEIGHT: float = 500.0 # player's height above the ground
const PLAYER_SPEED: int = 100
const FULL_ACCELERATION: float = 3.0 # move modifier for keyboard input
const CROSSAIR_DISTANCE: float = 600.0 # distance to the crossair when player is centered
const ROCKET_COOLDOWN: float = 0.15 # rocket fire delay
const MAX_DURABILITY: float = 100.0
const MAX_ROCKETS: int = 32 # max amount of rockets that player can carry
const FLARE_DIRECTIONS := [Vector3(-0.965926, 0, -0.258819), Vector3(-0.866025, 0, -0.5), Vector3(-0.707107, 0, -0.707107), Vector3(0.965926, 0, -0.258819), Vector3(0.866025, 0, -0.5), Vector3(0.707107, 0, -0.707107)
]
const FLARES_COOLDOWN := 10.0

var durability: float
var direction := Vector2.ZERO # current move normalized direction vector
var velocity: Vector2 # player local velocity per second
var rockets_amount: int = MAX_ROCKETS # available rockets
var rocket_consumption: int = 1 # for debug purposes
var damage_multiplier: int = 1 # for debug purposes
var engine_efficiency: float = 1.0 # 0.5-1.0


func apply_damage(value: int) -> void:
	pass

func get_height() -> float:
	return HEIGHT

func hit_by_rocket() -> void:
	pass

func game_over() -> void:
	pass
