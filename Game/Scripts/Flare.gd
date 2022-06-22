class_name Flare
extends Particles2D

const IMPULSE := 200
const LIFETIME := 4.0
const GRAVITY := Vector3(0, -50.0, 30.0)
const FRICTION := 50.0

var time: float
var position_3D: Vector3
var velocity_3D: Vector3
var gravity_local: Vector3
onready var trace: Particles2D = find_node("Trace")
onready var flash: Sprite = find_node("Flash")


func _process(delta: float) -> void:
	time += delta
	if time > LIFETIME:
		var opacity = self_modulate.a - delta
		if opacity < 0:
			deactivate()
		else:
			self_modulate.a = opacity
	
	velocity_3D = velocity_3D.move_toward(Vector3.ZERO, FRICTION * delta)
	velocity_3D += gravity_local * delta
	position_3D += velocity_3D * delta
	position = Vector2(position_3D.x, position_3D.z)
	var _scale = position_3D.y / PlayerBase.HEIGHT
	scale = Vector2.ONE * _scale

func get_height() -> float:
	return position_3D.y

func activate(pos: Vector3, rot: float, dir: Vector3, velocity: Vector3) -> void:
	if Global.game.midair_layer:
		Global.game.midair_layer.add_child(self)
		position_3D = pos
		gravity_local = GRAVITY.rotated(Vector3.UP, -rot)
		velocity_3D = dir * IMPULSE
		trace.process_material.direction = velocity.normalized()
		trace.process_material.initial_velocity = velocity.length()
		time = 0.0
		self_modulate.a = 1.0
		restart()
		trace.restart()
		set_process(true)
		GlobalTween.interpolate_property(flash, "self_modulate:a", 0.3, 0.0, 2.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT_IN)
		GlobalTween.start()

func deactivate() -> void:
	set_process(false)
	emitting = false
	trace.emitting = false
	yield(get_tree().create_timer(LIFETIME, false), "timeout") # wait for last emitted particles gone
	if is_inside_tree():
		get_parent().remove_child(self)
