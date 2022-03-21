extends Node2D

class_name Rocket

const SPEED: int = 400
const TANG_SPEED: float = 1.0
const INIT_HEIGHT: int = 500

onready var visual: Node2D = find_node("Visual")
onready var body: Sprite = find_node("Body")
onready var flame: Particles2D = find_node("Flame")
onready var trace: Particles2D = find_node("Trace")
onready var watchdog: Timer = find_node("WatchDog")
onready var reset_timer: Timer = find_node("ResetTimer")

var is_free: bool = true
#var direction: Vector2 = Vector2.UP # normalized move direction vector
var position_3D: Vector3
var direction_3D: Vector3
var destination_3D: Vector3


func _process(delta: float) -> void:
	var dir_to_dest = position_3D.direction_to(destination_3D)
	direction_3D = direction_3D.move_toward(dir_to_dest, TANG_SPEED * delta)
	var velocity_3D = direction_3D * SPEED * delta
	position_3D += velocity_3D
	
	if position_3D.y < 0:
		detonation()
	else:
		position += Vector2(velocity_3D.x, velocity_3D.z)
		global_rotation = -Vector2(direction_3D.x, direction_3D.z).angle_to(Vector2.UP)
		
		#deformations based on 3D height
		var _scale = position_3D.y / INIT_HEIGHT
		visual.scale = Vector2.ONE * _scale
	#	trace.process_material.scale = _scale

# activate (fire) the rocket. Initial position and normalized move direction both are in global coords
func activate(pos: Vector2, dir: Vector3, dest: Vector2) -> void:
	global_position = pos
	position_3D = Vector3(pos.x, INIT_HEIGHT, pos.y)
	direction_3D = dir
	global_rotation = -Vector2(direction_3D.x, direction_3D.z).angle_to(Vector2.UP)
	
	# add random spread offset to the destination point
	var _spread_value = (dest - pos).length() * Global.player.ROCKET_SPREAD
	var _x_spread = (randf() - 0.5) * _spread_value
	var _y_spread = (randf() - 0.5) * _spread_value
	destination_3D = Vector3(dest.x + _x_spread, 0, dest.y + _y_spread)
	
	is_free = false
	Global.midair_layer.add_child(self)
	flame.restart()
	trace.restart()
	watchdog.start()
	set_process(true)

# deactivate the rocket. Gives a delay for all animations to complete before returning to the pool
# will called automaticly by the timer (just in case to be sure)
func deactivate() -> void:
	set_process(false)
	watchdog.stop() # to avoid re-call
	body.visible = false
	flame.visible = false
	trace.emitting = false
	reset_timer.start()

# reset the rocket for future use via rocket pool. Called by timer
func reset() -> void:
	get_parent().remove_child(self)
#	visual.scale = Vector2.ONE
#	trace.process_material.scale = Vector2.ONE
	body.visible = true
	flame.visible = true
	is_free = true

func detonation():
	deactivate()
	var explosion: Explosion = ExplosionManager.get_explosion("RocketExplosion")
	explosion.activate(global_position)
