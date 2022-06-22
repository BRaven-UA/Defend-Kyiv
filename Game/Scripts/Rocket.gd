# main class for rocket entity
# contains only private fields and methods
extends RocketBase

var position_3D: Vector3
var direction_3D: Vector3
var shooter: Node2D
var target: Node2D
var square_distance: float
var warning_sign: WarningSign
var colliders: Array

onready var sound: AudioStreamPlayer2D = find_node("Sound")
onready var orig_max_distanse: float = sound.max_distance
onready var visual: Node2D = find_node("Visual")
onready var body: Sprite = find_node("Body")
onready var flame: Particles2D = find_node("Flame")
onready var trace: Particles2D = find_node("Trace")
onready var watchdog: Timer = find_node("WatchDog") # lifetime limit
onready var reset_timer: Timer = find_node("ResetTimer")


func _exit_tree() -> void:
	watchdog.stop()
	reset_timer.stop()

func _physics_process(delta: float) -> void:
	if target:
		var dest_2D: Vector2 = target.global_position
		var dest_3D = Vector3(dest_2D.x, target.get_height(), dest_2D.y)
		var dir_to_dest = position_3D.direction_to(dest_3D)
		direction_3D = direction_3D.move_toward(dir_to_dest, TANG_SPEED * delta)
		
		var new_square_distance = position_3D.distance_squared_to(dest_3D)
		if new_square_distance > square_distance: # miss the target
			set_target(null)
		else:
			square_distance = new_square_distance
	
	var velocity_3D = direction_3D * SPEED * delta
	position_3D += velocity_3D
	
	if position_3D.y < 0 or position_3D.y > PlayerBase.HEIGHT + 200.0: # landing or too high
		detonation()
	else:
		position += Vector2(velocity_3D.x, velocity_3D.z)
		global_rotation = -Vector2(direction_3D.x, direction_3D.z).angle_to(Vector2.UP)
		_scale()
		
		# check all 2D overlaping areas for their height
		for area in colliders:
			if abs(area.get_height() - position_3D.y) < 5.0:
				detonation()
				if area is PlayerBase:
					area.hit_by_rocket()

func get_height() -> float:
	return position_3D.y

func set_target(new_target: Node2D) -> void:
	if new_target is PlayerBase:
		warning_sign = PoolManager.get_warning_sign()
		warning_sign.activate(self)
		Global.game.player.connect("flares_used", self, "_on_player_flares_used", [], CONNECT_ONESHOT + CONNECT_REFERENCE_COUNTED)
	elif warning_sign:
		warning_sign.deactivate()
		warning_sign = null
	
	if target is Target:
		target.deactivate()
#		watchdog.start(2) # deactivate after this time
	
	target = new_target
	square_distance = INF

# activate (fire) the rocket. Initial position and normalized move direction both are in global coords
func activate(shoot: Node2D, pos: Vector3, dir: Vector3, new_target: Node2D) -> void:
	if Global.game.midair_layer:
		shooter = shoot
		position_3D = pos
		direction_3D = dir
		global_position = Vector2(pos.x, pos.z)
		global_rotation = -Vector2(dir.x, dir.z).angle_to(Vector2.UP)
		set_target(new_target)
		square_distance = INF
		Global.game.midair_layer.add_child(self)
		_scale()
		flame.restart()
		trace.restart()
		watchdog.start(20)
		colliders = []
		set_deferred("monitorable", true)
		body.visible = true
		flame.visible = true
		set_physics_process(true)

# deactivate the rocket. Gives a delay for all animations to complete before returning to the pool
# will called automaticly by the timer (just in case to be sure)
func deactivate() -> void:
	set_target(null)
	set_physics_process(false)
	set_deferred("monitorable", false)
	sound.stop()
	watchdog.stop() # to avoid re-call
	body.visible = false
	flame.visible = false
	trace.emitting = false
	reset_timer.start()

# reset the rocket for future use via rocket pool. Called by timer
func reset() -> void:
	if is_inside_tree():
		get_parent().remove_child(self)

func detonation() -> void:
	deactivate()
	var is_aerial: bool = position_3D.y > 10
	var type = PoolManager.EXPLOSION.AerialExplosion if is_aerial else PoolManager.EXPLOSION.RocketExplosion
	var explosion: Explosion = PoolManager.get_explosion(type)
	Global.game.above_ground_layer.add_child(explosion)
	explosion.activate(position_3D)

# deformations based on height above the ground
func _scale() -> void:
	var _scale = position_3D.y / PlayerBase.HEIGHT
	visual.scale = Vector2.ONE * _scale
	sound.max_distance = orig_max_distanse * _scale

func _on_player_flares_used(flares: Array) -> void:
	flares.shuffle()
	set_target(flares[0])

func _on_area_entered(area: Area2D) -> void:
	if area != shooter:
		colliders.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area != shooter:
		colliders.erase(area)
