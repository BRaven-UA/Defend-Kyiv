class_name Player
extends Area2D

signal ammo_changed(value)

const HEIGHT: int = 500 # player's height above the ground
const PLAYER_SPEED: int = 100
const FULL_ACCELERATION: float = 3.0 # move modifier for keyboard input
const CROSSAIR_DISTANCE: float = 600.0 # distance to the crossair when player is centered
const ROCKET_SPREAD: float = 0.08 # rocket spread in percent (0-1)
const ROCKET_COOLDOWN: float = 0.15 # rocket fire delay
const MAX_ROCKETS: int = 32 # max amount of rockets that player can carry

onready var shadow: Sprite = find_node("Shadow")
onready var crossair: Sprite = find_node("Crossair")
onready var highlight: Area2D = find_node("Highlight") # an area of highlighted vehicles with preview
onready var pusher: KinematicBody2D = find_node("BalloonPusher") # a physics body that pushes off preview balloons
onready var animation_tree: AnimationTree = find_node("AnimationTree") # blend space animation
onready var rocket_timer: Timer = find_node("RocketTimer")
onready var ammo_timer: Timer = find_node("AmmoReplenishTimer")
var analog_controller: AnalogController # touchscreen movement controller

var direction := Vector2.ZERO # current move normalized direction vector
var horizontal_limit: int # screen boundaries
var vertical_limit: int

var rocket_launchers: Array # list of the two available rocket launchers
var current_rocket_launcher_index: int # index of current launcher
var rockets_amount: int = MAX_ROCKETS # available rockets
var rocket_consumption: int = 1 # for debug purposes
var ready_to_fire: bool = true


func _enter_tree() -> void:
	Global.player = self # register itself in global singleton
	Global.viewport_size = get_viewport_rect().size

func _ready() -> void:
	analog_controller = Global.analog_controller
	if Global.hud:
		connect("ammo_changed", Global.hud, "set_ammo")
	
	rocket_launchers.resize(2)
	rocket_launchers[0] = find_node("RocketLauncher1")
	rocket_launchers[1] = find_node("RocketLauncher2")
	rocket_timer.connect("timeout", self, "_on_RocketTimer_timeout")
	ammo_timer.connect("timeout", self, "_on_AmmoTimer_timeout")
	
	# calculating screen boundaries
	var player_extents = find_node("Hitbox").shape.extents # player boundaries
	horizontal_limit = Global.viewport_size.x / 2 - player_extents.x
	vertical_limit = Global.viewport_size.y / 2 - player_extents.y

func _process(delta: float) -> void:
	_moving(delta)
	
	# setting animation
	animation_tree.set("parameters/Direction/blend_position", direction)
	
	# adjust shadow position
	shadow.global_position = global_position + Global.SHADOW * 100
	
	# moving the crossair, highlight area and preview pusher
	var _pos = (direction.reflect(Vector2.RIGHT) / 2 + Vector2.UP) * Vector2(CROSSAIR_DISTANCE * direction.y, CROSSAIR_DISTANCE) # Y-axis is inverted in 2D
	crossair.position = _pos
	highlight.position = _pos
	pusher.position = _pos
	var _spread_value = _pos.length() * ROCKET_SPREAD
	crossair.scale = Vector2.ONE * (_spread_value / 40.0) # default scale equal to 40 meters spread
	
	if Input.is_action_pressed("fire_rocket") and ready_to_fire and rockets_amount:
		fire_rocket()

func _moving(delta: float):
	# calculating user input vector
	var input_vector := Vector2.ZERO
	
	input_vector.x += Input.get_action_strength("ui_right")
	input_vector.x -= Input.get_action_strength("ui_left")
	input_vector.y += Input.get_action_strength("ui_up")
	input_vector.y -= Input.get_action_strength("ui_down")
	
	if analog_controller:
		input_vector += analog_controller.currentForce # combine with touch input
	
	var input_length = input_vector.length()
	if input_length > 1.0: # normalize ONLY oversized vector
		input_vector = input_vector.normalized()
	
	# direction vector adjustment based on user input
	var acceleration = delta * (FULL_ACCELERATION if Input.is_action_pressed("full_acceleration") else 1.0)
	
	if input_length < 0.1: # lesser than input zead zone or no input at all
		# the move direction tends to zero
		direction = direction.move_toward(Vector2.ZERO, acceleration)
	#	direction = direction.move_toward(Vector2.ZERO, resist_delta)
	else: # valid input values
		direction += input_vector.reflect(Vector2.RIGHT) * acceleration # Y-axis is inverted in 2D
		direction = direction.clamped(1)
	
	# move player
	position += direction * PLAYER_SPEED * acceleration
	position.x = clamp(position.x, -horizontal_limit, horizontal_limit)
	position.y = clamp(position.y, -vertical_limit, vertical_limit)

func fire_rocket() -> void:
	var launcher: RocketLauncher = rocket_launchers[current_rocket_launcher_index]
	
	var dir_3D_local = (Vector3(direction.x * direction.y, direction.y, abs(direction.y) - 2.0) * 0.5).normalized()
	var dir_3D_global = dir_3D_local.rotated(Vector3.UP, -global_rotation)
	var pos: Vector2 = launcher.global_position #+ dir_2D_global * 20 # plus launcher length
	var dest: Vector2 = crossair.global_position
	
	var rocket: Rocket = PoolManager.get_rocket()
	rocket.activate(pos, dir_3D_global, dest)
	launcher.activate(Vector2(dir_3D_global.x, dir_3D_global.z))
	
	_change_rockets_amount(-rocket_consumption)
	ready_to_fire = false
	rocket_timer.start(ROCKET_COOLDOWN)
	current_rocket_launcher_index = current_rocket_launcher_index ^ 1 # swap 0 and 1

func _change_rockets_amount(value: int) -> void:
	var new_value = Global.clamp_int(rockets_amount + value, 0, MAX_ROCKETS)
	if new_value != rockets_amount:
		rockets_amount = new_value
		emit_signal("ammo_changed", rockets_amount)

func _on_RocketTimer_timeout() -> void:
	ready_to_fire = true

func _on_AmmoTimer_timeout() -> void:
	_change_rockets_amount(1)
