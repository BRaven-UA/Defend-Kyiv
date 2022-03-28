extends StaticBody2D

var is_moving: bool

func _input_event(viewport: Object, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		is_moving = event.pressed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_moving:
		position += event.relative
