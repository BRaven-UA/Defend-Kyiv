extends Area2D

class_name Rocket

onready var body: Sprite = $Body
onready var flame: Particles2D = $Flame
onready var trace: Particles2D = $Trace
onready var watchdog: Timer = $WatchDog
onready var reset_timer: Timer = $ResetTimer

var is_free: bool = true
var direction: Vector2 = Vector2.UP # normalized move direction vector


#func _ready() -> void:
#	body = $Body
#	flame = $Flame
#	trace = $Trace
#	watchdog = $WatchDog

func _physics_process(delta: float) -> void:
	position += direction * delta * 500

# activate (fire) the rocket. Initial position and move direction both are in global coords
func activate(pos: Vector2 = Vector2.ZERO, dir: Vector2 = Vector2.UP) -> void:
	global_position = pos
	global_rotation = -dir.angle_to(Vector2.UP)
	direction = dir
	is_free = false
	Global.main.add_child(self)
	flame.restart()
	trace.restart()
	watchdog.start()

# deactivate the rocket. Gives a delay for all animations to complete before returning to the pool
# will called automaticly by the timer (just in case to be sure)
func deactivate() -> void:
	watchdog.stop() # to avoid re-call
	body.visible = false
	flame.visible = false
	trace.emitting = false
	collision_mask = 0
	reset_timer.start()

# reset the rocket for future use via rocket pool. Called by timer
func reset() -> void:
	get_parent().remove_child(self)
	body.visible = true
	flame.visible = true
	is_free = true
