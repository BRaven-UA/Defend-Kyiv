# main class for rocket entity
# contains only private fields and methods
extends RocketBase

var position_3D: Vector3
var direction_3D: Vector3
var shooter: Node2D
var target: Node2D
var square_distance: float
var colliders: Array

onready var sound: AudioStreamPlayer2D = find_node("Sound")
onready var orig_max_distanse: float = sound.max_distance
onready var visual: Node2D = find_node("Visual")
onready var body: Sprite = find_node("Body")
onready var flame: Particles2D = find_node("Flame")
onready var trace: Particles2D = find_node("Trace")
onready var watchdog: Timer = find_node("WatchDog")
onready var reset_timer: Timer = find_node("ResetTimer")


func _physics_process(delta: float) -> void:
	if target:
		var dest_2D: Vector2 = target.global_position
		var dest_3D = Vector3(dest_2D.x, target.HEIGHT, dest_2D.y)
		var dir_to_dest = position_3D.direction_to(dest_3D)
		direction_3D = direction_3D.move_toward(dir_to_dest, TANG_SPEED * delta)
		
		var new_square_distance = position_3D.distance_squared_to(dest_3D)
		if new_square_distance > square_distance: # miss the target
			target = null
			if target is Target:
				target.queue_free()
			watchdog.start(2) # deactivate after this time
		else:
			square_distance = new_square_distance
	
	var velocity_3D = direction_3D * SPEED * delta
	position_3D += velocity_3D
	
	if position_3D.y < 0: # landing
		detonation()
	else:
		position += Vector2(velocity_3D.x, velocity_3D.z)
		global_rotation = -Vector2(direction_3D.x, direction_3D.z).angle_to(Vector2.UP)
		_scale()
		
		# check all 2D overlaping areas for their height
		for area in colliders:
			if abs(area.get_height() - position_3D.y) < 5.0:
				detonation()

func get_height() -> float:
	return position_3D.y

# activate (fire) the rocket. Initial position and normalized move direction both are in global coords
func activate(shoot: Node2D, pos: Vector3, dir: Vector3, tar: Node2D) -> void:
	shooter = shoot
	position_3D = pos
	direction_3D = dir
	global_position = Vector2(pos.x, pos.z)
	global_rotation = -Vector2(dir.x, dir.z).angle_to(Vector2.UP)
	target = tar
	square_distance = INF
	is_free = false
	Global.midair_layer.add_child(self)
	_scale()
	flame.restart()
	trace.restart()
	watchdog.start(20)
	set_physics_process(true)

# deactivate the rocket. Gives a delay for all animations to complete before returning to the pool
# will called automaticly by the timer (just in case to be sure)
func deactivate() -> void:
	colliders = []
	set_physics_process(false)
	sound.stop()
	watchdog.stop() # to avoid re-call
	body.visible = false
	flame.visible = false
	trace.emitting = false
	reset_timer.start()

# reset the rocket for future use via rocket pool. Called by timer
func reset() -> void:
	get_parent().remove_child(self)
	body.visible = true
	flame.visible = true
	is_free = true

func detonation() -> void:
	deactivate()
	var is_aerial: bool = position_3D.y > 50
	var type = PoolManager.EXPLOSION.AerialExplosion if is_aerial else PoolManager.EXPLOSION.RocketExplosion
	var explosion: Explosion = PoolManager.get_explosion(type)
	explosion.activate(global_position, is_aerial)

# deformations based on height above the ground
func _scale() -> void:
	var _scale = position_3D.y / PlayerBase.HEIGHT
	visual.scale = Vector2.ONE * _scale
	sound.max_distance = orig_max_distanse * _scale

func _on_area_entered(area: Area2D) -> void:
	if area != shooter:
		colliders.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area != shooter:
		colliders.erase(area)
