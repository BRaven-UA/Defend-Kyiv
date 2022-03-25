extends Control


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			Input.action_press("fire_rocket")
		else:
			Input.action_release("fire_rocket")
