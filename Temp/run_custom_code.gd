tool
extends EditorScript


func _run() -> void:
	print((Vector2(-1, -1) / 2 + Vector2.DOWN) * Vector2(100, 500))
