extends Node2D

class_name Preview

onready var anchor: StaticBody2D = find_node("Anchor")
onready var balloon: RigidBody2D = find_node("Balloon")
onready var frame: Sprite = find_node("PreviewFrame")
onready var shadow: Sprite = find_node("PreviewShadow")
onready var picture: Sprite = find_node("PreviewPicture")
onready var layer := balloon.collision_layer


func _process(delta: float) -> void:
	frame.position = balloon.position
	var _direction = frame.position - anchor.position
	frame.rotation = _direction.angle() - 0.785398 # since the texture points to 45 degrees counterclockwise
	shadow.position = Global.SHADOW.rotated(-shadow.global_rotation) * 7.0
	picture.global_rotation = Global.game.player.global_rotation

func init(pos: Vector2, frame_index: int, color: Color) -> void:
	deactivate()
	global_position = pos
	picture.frame = frame_index
	frame.self_modulate = color
	frame.scale = Vector2.ZERO

func activate() -> void:
	balloon.collision_layer = layer # collide also with visible balloons
	set_process(true)
	GlobalTween.show_up_preview(frame)

# disable physics, processing and showing
func deactivate() -> void:
	balloon.collision_layer = 0
#	balloon.set_collision_layer_bit(9, true) # collide only with the pusher
	set_process(false)
	GlobalTween.fade_preview(frame)
