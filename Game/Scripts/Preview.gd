extends Node2D

class_name Preview

onready var anchor: StaticBody2D = find_node("Anchor")
#onready var rope: DampedSpringJoint2D = find_node("Rope")
onready var balloon: RigidBody2D = find_node("Balloon")
onready var frame: Sprite = find_node("PreviewFrame")
onready var shadow: Sprite = find_node("PreviewShadow")
onready var picture: Sprite = find_node("PreviewPicture")
onready var layers := balloon.layers

var is_animated := false

func _process(delta: float) -> void:
	frame.position = balloon.position
	var _direction = frame.position - anchor.position
	frame.rotation = _direction.angle() - 0.785398 # since the texture points to 45 degrees counterclockwise
	shadow.global_position = frame.global_position + Global.SHADOW * 5.0
	picture.global_rotation = Global.player.global_rotation

func init(pos: Vector2, frame_index: int, color: Color) -> void:
	yield(self, "ready")
	_deactivate()
	global_position = pos
	picture.frame = frame_index
	frame.self_modulate = color

func activate() -> void:
	balloon.layers = layers # collide also with visible balloons
	set_process(true)
	frame.visible = true
	is_animated = true
	GlobalTween.show_up_preview(self)
	is_animated = false

func deactivate(delete := false) -> void:
	if frame.visible:
		var duration = GlobalTween.fade_preview(self)
		# waiting for the end of the animation
		is_animated = true
		yield(get_tree().create_timer(duration), "timeout")
		is_animated = false
	if delete and not is_animated: # delete this preview when the enemy is destroyed
		queue_free()
	else:
		_deactivate()

func _deactivate() -> void:
	balloon.layers = 0
	balloon.set_collision_layer_bit(9, true) # collide only with the pusher
	set_process(false)
	frame.visible = false
