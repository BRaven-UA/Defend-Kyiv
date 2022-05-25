extends BackBufferCopy


func _draw() -> void:
	var rect = get_viewport_rect()
	rect = Rect2(-rect.size, rect.size * 2)
	draw_rect(rect, Color.white)
