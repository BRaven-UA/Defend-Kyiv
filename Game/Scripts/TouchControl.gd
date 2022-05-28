extends TextureButton

func _ready() -> void:
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture_disabled.get_data())
	texture_click_mask = bitmap
	
	connect("button_down", self, "_on_button_down")
	connect("button_up", self, "_on_button_up")

#func _gui_input(event: InputEvent) -> void:
#	if event is InputEventScreenTouch:
#		pass

func _send_action(state: bool) -> void:
	var event = InputEventAction.new()
	event.action = "fire_rocket"
	event.pressed = state
	Input.parse_input_event(event)

func _on_button_down() -> void:
	_send_action(true)

func _on_button_up() -> void:
	_send_action(false)
