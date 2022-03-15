extends Area2D

const PLAYER_SPEED: int = 100
const FULL_ACCELERATION: float = 3.0 # move modifier for keyboard input
#const CENTERING_FORCE: float = 2.0 # 
const CROSSAIR_DISTANCE: float = 600.0 # distance to the crossair when player is centered
const ROCKET_COOLDOWN: float = 0.15 # rocket fire delay

onready var animation_tree: AnimationTree = $AnimationTree # blend space animation
onready var rocket_timer: Timer = $RocketTimer
onready var crossair: Sprite = $Crossair
var analog_controller: AnalogController # touchscreen movement controller

var direction := Vector2.ZERO # current move normalized direction vector
var horizontal_limit: int # screen boundaries
var vertical_limit: int

var rocket_launchers: Array # list of the two available rocket launchers
var current_rocket_launcher_index: int # index of current launcher
var rocket_pool: Array # list of all rocket instances
var can_fire_rocket: bool = true


func _ready() -> void:
	analog_controller = Global.analog_controller
	rocket_launchers.resize(2)
	rocket_launchers[0] = $RocketLauncher1
	rocket_launchers[1] = $RocketLauncher2
	rocket_timer.connect("timeout", self, "_on_RocketTimer_timeout")
	
	# calculating screen boundaries
	var player_extents = $CollisionShape2D.shape.extents # player boundaries
	var viewport_size = get_viewport_rect().size
	horizontal_limit = viewport_size.x / 2 - player_extents.x
	vertical_limit = viewport_size.y / 2 - player_extents.y

func _process(delta: float) -> void:
	_moving(delta)
	
	# setting animation
	animation_tree.set("parameters/Direction/blend_position", direction)
	
	# moving the crossair
	crossair.position = (direction.reflect(Vector2.RIGHT) / 2 + Vector2.UP) * Vector2(-CROSSAIR_DISTANCE, CROSSAIR_DISTANCE) # Y-axis is inverted in 2D
	
	if Input.is_action_pressed("fire_rocket") and can_fire_rocket:
		fire_rocket()

func _moving(delta: float):
	# calculating user input vector
	var input_vector := Vector2.ZERO
	
	input_vector.x += Input.get_action_strength("ui_right")
	input_vector.x -= Input.get_action_strength("ui_left")
	input_vector.y += Input.get_action_strength("ui_up")
	input_vector.y -= Input.get_action_strength("ui_down")
	
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
	var dir = Vector2.UP.rotated(global_rotation)
	var pos: Vector2 = launcher.global_position + dir * 10 # plus launcher length
	var rocket: Rocket = get_rocket()
	launcher.activate()
	rocket.activate(pos, dir)
	can_fire_rocket = false
	rocket_timer.start(ROCKET_COOLDOWN)
	current_rocket_launcher_index = current_rocket_launcher_index ^ 1 # swap 0 and 1

func _on_RocketTimer_timeout() -> void:
	can_fire_rocket = true

func get_rocket() -> Rocket: # get reference to new rocket from the rocket pool
	for rocket in rocket_pool: # search for free rocket
		if rocket.is_free:
			return rocket
	
	# add new instance to the pool if there no free rockets left
	var new_rocket = Preloader.get_resource("Rocket").instance()
	rocket_pool.append(new_rocket)
	return new_rocket
	