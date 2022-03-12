extends Area2D

const PLAYER_SPEED: int = 300
const RESISTANCE: float = 2.0 # risistance of the environment factor

var direction := Vector2.ZERO # current move normalized direction vector
var horizontal_limit: int # screen boundaries
var vertical_limit: int
var animation_tree: AnimationTree # blend space animation
var analog_controller: AnalogController # touchscreen movement controller


func _ready() -> void:
	animation_tree = $AnimationTree
	analog_controller = Global.analog_controller
	
	# calculating screen boundaries
	var player_extents = $CollisionShape2D.shape.extents # player boundaries
	var viewport_size = get_viewport_rect().size
	horizontal_limit = viewport_size.x / 2 - player_extents.x
	vertical_limit = viewport_size.y / 2 - player_extents.y

func _process(delta: float) -> void:
	var resist_delta: float = RESISTANCE * delta
	
	# the move direction tends to zero
	direction = direction.move_toward(Vector2.ZERO, resist_delta)
	
	# calculating user input vector
	var input_vector := Vector2.ZERO
	
	input_vector.x += Input.get_action_strength("ui_right")
	input_vector.x -= Input.get_action_strength("ui_left")
	input_vector.y += Input.get_action_strength("ui_up")
	input_vector.y -= Input.get_action_strength("ui_down")
	
	input_vector += analog_controller.currentForce # combine with touch input
	
	if input_vector.length() > 1.0: # normalize ONLY oversized vector
		input_vector = input_vector.normalized()
	
	# direction vector adjustment based on user input
	direction += input_vector.reflect(Vector2.RIGHT) * resist_delta * 2 #FIXME: Y-axis mirroring
	direction = direction.clamped(1)
	
	Global.debug_label_1.text = str(direction)
	Global.debug_label_2.text = str(analog_controller.currentForce)
	
	# move player
	position += direction * delta * PLAYER_SPEED
#	var velocity: Vector2 = direction * delta * PLAYER_SPEED
#	position += velocity.rotated(-rotation)
	position.x = clamp(position.x, -horizontal_limit, horizontal_limit)
	position.y = clamp(position.y, -vertical_limit, vertical_limit)
	
	# setting animation
	animation_tree.set("parameters/Direction/blend_position", direction)
