extends Sprite

var path: PathFollow2D

func _ready() -> void:
	path = Global.Path_Follow

func _process(delta: float) -> void:
	# correction of the position of the shadow based on the rotation of the path_follow node
	position = Vector2(-82, -52).rotated(-path.rotation)
