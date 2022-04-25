extends Control

class_name Debug

onready var player: Player = Global.player
onready var scene_tree: SceneTree = get_tree()
onready var panel: Panel = find_node("DebugPanel")
onready var debug_label_1: Label = find_node("DebugLabel_1")
onready var debug_label_2: Label = find_node("DebugLabel_2")
onready var scroll_speed_label: Label = find_node("ScrollSpeedLabel")
onready var scroll_speed_slider: Slider = find_node("ScrollSpeedSlider")
onready var reset_position: Button = find_node("ResetPosition")
onready var infinite_ammo: CheckButton = find_node("InfiniteAmmoSwitch")
onready var always_on_top: CheckButton = find_node("AlwaysOnTopSwitch")

var player_rocket_consumption: int # backup value


func _enter_tree() -> void:
	Global.debug = self # register itself in global singleton

func _ready() -> void:
	debug_panel(0) # make sure start hidden
	
	scroll_speed_slider.connect("value_changed", self, "_on_scroll_speed_changed")
	_on_scroll_speed_changed(Global.path_follow.scroll_speed)
	
	reset_position.connect("pressed", self, "_on_reset_position")
	
	if player:
		player_rocket_consumption = player.rocket_consumption
		infinite_ammo.connect("toggled", self, "_on_infinite_ammo_toggled")
	
	always_on_top.pressed = OS.is_window_always_on_top()
	always_on_top.connect("toggled", self, "_on_always_on_top_toggled")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_panel"):
		debug_panel()
	if event.is_action_pressed("ui_cancel"):
		scene_tree.paused = !scene_tree.paused

func debug_panel(state: int = -1): # three state workaround: 0 - false, 1 - true, -1 - toggle
	var _visible: bool
	if state == -1: # toggle by default
		_visible = !panel.visible
	else:
		_visible = state as bool # type casting
	panel.visible = _visible

func _on_reset_position() -> void:
	Global.path_follow.reset_position()

func _on_scroll_speed_changed(value: float) -> void:
	Global.path_follow.set_scroll_speed(value)
	scroll_speed_label.text = "Scroll speed: %d" % value as int

func _on_infinite_ammo_toggled(enabled: bool) -> void:
	if enabled:
		player.rockets_amount = player.MAX_ROCKETS
		player.rocket_consumption = 0
	else:
		player.rocket_consumption = player_rocket_consumption

func _on_always_on_top_toggled(state: bool) -> void:
	OS.set_window_always_on_top(state)
