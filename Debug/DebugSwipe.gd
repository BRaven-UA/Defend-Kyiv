extends Control

const SENSITIVITY: float = 15.0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		print(event.relative.x)
		if event.relative.x > SENSITIVITY: # right swipe
			Global.debug.debug_panel(1)
			return
		if event.relative.x < -SENSITIVITY: # left swipe
			Global.debug.debug_panel(0)
