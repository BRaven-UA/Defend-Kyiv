class_name Debug
extends Control

var player_rocket_consumption: int # backup value

#onready var player: PlayerBase = Global.game.player
onready var tree: SceneTree = get_tree()
onready var panel: Panel = find_node("DebugPanel")
onready var debug_label_1: Label = find_node("DebugLabel_1")
onready var debug_label_2: Label = find_node("DebugLabel_2")
onready var scroll_speed_label: Label = find_node("ScrollSpeedLabel")
onready var scroll_speed_slider: Slider = find_node("ScrollSpeedSlider")
onready var reset_position: Button = find_node("ResetPosition")
onready var restart: Button = find_node("RestartGame")
onready var infinite_ammo: CheckButton = find_node("InfiniteAmmoSwitch")
onready var invulnerable: CheckButton = find_node("InvulnerableSwitch")
onready var always_on_top: CheckButton = find_node("AlwaysOnTopSwitch")
onready var resizeable: CheckButton = find_node("ResizeableSwitch")


func _enter_tree() -> void:
	Global.debug = self # register itself in global singleton

func _ready() -> void:
	debug_panel(0) # make sure to start hidden
	init()
	scroll_speed_slider.connect("value_changed", self, "_on_scroll_speed_changed")
	reset_position.connect("pressed", self, "_on_reset_position_pressed")
	restart.connect("pressed", self, "_on_restart_pressed")
	infinite_ammo.connect("toggled", self, "_on_infinite_ammo_toggled")
	invulnerable.connect("toggled", self, "_on_invulnerable_toggled")
	always_on_top.connect("toggled", self, "_on_always_on_top_toggled")
	resizeable.connect("toggled", self, "_on_resizeable_toggled")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_panel"):
		debug_panel()

func init() -> void:
	debug_label_1.text = ""
	debug_label_2.text = ""
	always_on_top.pressed = OS.is_window_always_on_top()
	resizeable.pressed = OS.window_resizable
	
	if Global.game:
		var speed = Global.game.path_follow.scroll_speed
		scroll_speed_slider.value = speed
		_on_scroll_speed_changed(speed)
		infinite_ammo.pressed = false
		invulnerable.pressed = false

func debug_panel(state: int = -1): # three state workaround: 0 - false, 1 - true, -1 - toggle
	var _visible: bool
	if state == -1: # toggle by default
		_visible = !panel.visible
	else:
		_visible = state as bool # type casting
	panel.visible = _visible
	
	var is_ingame = Global.game != null
	if _visible:
		if is_ingame:
			_on_scroll_speed_changed(Global.game.path_follow.scroll_speed)
		for node in tree.get_nodes_in_group("GameDebug"):
			node.visible = is_ingame

func _on_reset_position_pressed() -> void:
	if Global.game.path_follow:
		Global.game.path_follow.reset_position()

func _on_restart_pressed() -> void:
	PoolManager.return_all_reusable()
#	tree.reload_current_scene()
	Global.new_game()

func _on_scroll_speed_changed(value: float) -> void:
	if Global.game.path_follow:
		Global.game.path_follow.set_scroll_speed(value)
		scroll_speed_label.text = "Scroll speed: %d" % value as int

func _on_infinite_ammo_toggled(enabled: bool) -> void:
	if Global.game.player:
		if enabled:
			player_rocket_consumption = Global.game.player.rocket_consumption
			Global.game.player.rockets_amount = PlayerBase.MAX_ROCKETS
			Global.game.player.rocket_consumption = 0
		else:
			Global.game.player.rocket_consumption = player_rocket_consumption

func _on_invulnerable_toggled(enabled: bool) -> void:
	if Global.game.player:
		if enabled:
			Global.game.player.damage_multiplier = 0
			Global.game.player.durability = PlayerBase.MAX_DURABILITY
			Global.game.player.emit_signal("durability_changed", PlayerBase.MAX_DURABILITY)
		else:
			Global.game.player.damage_multiplier = 1

func _on_always_on_top_toggled(state: bool) -> void:
	OS.set_window_always_on_top(state)

func _on_resizeable_toggled(state: bool) -> void:
	OS.window_resizable = state
