extends TextureButton

var index: int = -1


#func _ready() -> void:
#	var bitmap = BitMap.new()
#	bitmap.create_from_image_alpha(texture_normal.get_data()) # DOESN'T WORK with atlas!
#	texture_click_mask = bitmap
	
#	connect("button_down", self, "_on_button_down")
#	connect("button_up", self, "_on_button_up")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		printt(event, event.index, event.pressed)
		if event.pressed:
			Input.action_press("fire_rocket")
		else:
			Input.action_release("fire_rocket")

#func _on_button_down() -> void:
#	Input.action_press("fire_rocket")
#
#func _on_button_up() -> void:
#	Input.action_release("fire_rocket")
