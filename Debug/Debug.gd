extends Control

class_name Debug

onready var scene_tree: SceneTree = get_tree()
onready var panel: BoxContainer = find_node("DebugPanel")
onready var debug_label_1: Label = find_node("DebugLabel_1")
onready var debug_label_2: Label = find_node("DebugLabel_2")
onready var scroll_speed_label: Label = find_node("ScrollSpeedLabel")
onready var scroll_speed_slider: Slider = find_node("ScrollSpeedSlider")
onready var reset_position: Button = find_node("ResetPosition")

func _enter_tree() -> void:
	Global.debug = self # register itself in global singleton

func _ready() -> void:
	debug_panel(0) # make sure start hidden
	scroll_speed_slider.connect("value_changed", self, "_on_scroll_speed_changed")
	reset_position.connect("pressed", self, "_on_reset_position")
	_on_scroll_speed_changed(Global.path_follow.scroll_speed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_panel"):
		debug_panel()
	if event.is_action_pressed("ui_cancel"):
		scene_tree.paused = !scene_tree.paused

func _on_reset_position() -> void:
	Global.path_follow.reset_position()

func _on_scroll_speed_changed(value: float) -> void:
	Global.path_follow.set_scroll_speed(value)
	scroll_speed_label.text = "Scroll speed: %d" % value as int

func debug_panel(state: int = -1): # three state workaround: 0 - false, 1 - true, -1 - toggle
	var _visible: bool
	if state == -1: # toggle by default
		_visible = !panel.visible
	else:
		_visible = state as bool # type casting
	panel.visible = _visible

