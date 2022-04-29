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

#var analog_controller: AnalogController # touchscreen movement controller
#var direction := Vector2.ZERO # current move normalized direction vector
#var horizontal_limit: int # screen boundaries
#var vertical_limit: int

#var rocket_launchers: Array # list of the two available rocket launchers
#var current_rocket_launcher_index: int # index of current launcher
var rockets_amount: int = MAX_ROCKETS # available rockets
var rocket_consumption: int = 1 # for debug purposes
#var ready_to_fire: bool = true

#onready var shadow: Sprite = find_node("Shadow")
#onready var crossair: Sprite = find_node("Crossair")
#onready var highlight: Area2D = find_node("Highlight") # an area of highlighted vehicles with preview
#onready var pusher: KinematicBody2D = find_node("BalloonPusher") # a physics body that pushes off preview balloons
#onready var animation_tree: AnimationTree = find_node("AnimationTree") # blend space animation
#onready var rocket_timer: Timer = find_node("RocketTimer")
#onready var ammo_timer: Timer = find_node("AmmoReplenishTimer")


func get_height() -> float:
	return HEIGHT
