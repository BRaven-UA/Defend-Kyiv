extends Node2D

class_name Preview

onready var anchor: StaticBody2D = find_node("Anchor")
onready var balloon: RigidBody2D = find_node("Balloon")
onready var frame: Sprite = find_node("PreviewFrame")
onready var shadow: Sprite = find_node("PreviewShadow")
onready var picture: Sprite = find_node("PreviewPicture")
onready var layers := balloon.layers


func _process(delta: float) -> void:
	frame.position = balloon.position
	var _direction = frame.position - anchor.position
	frame.rotation = _direction.angle() - 0.785398 # since the texture points to 45 degrees counterclockwise
	shadow.global_position = frame.global_position + Global.SHADOW * 5.0
	picture.global_rotation = Global.player.global_rotation

func init(pos: Vector2, frame_index: int, color: Color) -> void:
	deactivate()
	global_position = pos
	picture.frame = frame_index
	frame.self_modulate = color

func activate() -> void:
	balloon.layers = layers # collide also with visible balloons
	set_process(true)
	GlobalTween.show_up_preview(self)

# disable physics, processing and showing
func deactivate() -> void:
	balloon.layers = 0
	balloon.set_collision_layer_bit(9, true) # collide only with the pusher
	set_process(false)
	GlobalTween.fade_preview(self)
