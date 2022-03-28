extends Node2D

class_name Preview

onready var anchor: StaticBody2D = find_node("Anchor")
onready var rope: DampedSpringJoint2D = find_node("Rope")
onready var balloon: RigidBody2D = find_node("Balloon")
onready var frame: Sprite = find_node("PreviewFrame")
onready var shadow: Sprite = find_node("PreviewShadow")
onready var picture: Sprite = find_node("PreviewPicture")
onready var balloon_col_layer: int = balloon.collision_layer # balloon's default collision layer
onready var balloon_node_path: NodePath = rope.node_b # balloon's default node path

func _process(delta: float) -> void:
	frame.position = balloon.position
	var _direction = frame.position - anchor.position
	frame.rotation = _direction.angle() - 0.785398 # since the texture points to 45 degrees counterclockwise
	shadow.global_position = frame.global_position + Global.SHADOW * 5.0
#	picture.position = balloon.position
	picture.global_rotation = Global.player.global_rotation

func activate(pos: Vector2, texture: Texture, color: Color) -> void:
	global_position = pos
	picture.texture = texture
	frame.self_modulate = color
	balloon.collision_layer = balloon_col_layer
	balloon.mode = RigidBody2D.MODE_RIGID
#	rope.node_b = balloon_node_path
	set_process(true)
	visible = true

func deactivate() -> void:
#	rope.node_b = PreviewManager.EMPTY_PATH
	balloon.mode = RigidBody2D.MODE_STATIC
	balloon.collision_layer = 0
	balloon.linear_velocity = Vector2.ZERO
	balloon.angular_velocity = 0
	balloon.position = Vector2.ZERO
	set_process(false)
	visible = false
