class_name HUD
extends CanvasLayer

var touch_controls: Node2D
var analog_controller: AnalogController
onready var base: Control = $BaseControl
onready var durability_bar: ProgressBar = base.find_node("DurabilityBar")
onready var ammo_bar: TextureProgress = base.find_node("AmmoBar")
onready var score_bar: ProgressBar = base.find_node("ScoreBar")
onready var score_label: Label = base.find_node("ScoreLabel")
onready var warnings: Control = base.find_node("Warnings")
onready var gameover_caption: Label = base.find_node("GameoverCaption")
onready var flag_ru: ColorRect = base.find_node("FlagRU")
onready var flag_ua: ColorRect = base.find_node("FlagUA")
onready var statistics: PanelContainer = base.find_node("Statistics")
onready var statistic_units: GridContainer = base.find_node("StatisticUnits")
onready var total_score: Label = base.find_node("TotalScore")
onready var pause_menu: Panel = base.find_node("PauseMenu")
onready var resume: Button = pause_menu.find_node("Resume")
onready var settings: Button = pause_menu.find_node("Settings")
onready var main_menu: Button = pause_menu.find_node("MainMenu")
onready var anthem: AudioStreamPlayer = base.find_node("Anthem")


func _enter_tree() -> void:
	Global.game.hud = self # register itself in global singleton

func _ready() -> void:
	Global.game.connect("pause_changed", self, "_on_game_pause_changed")
	resume.connect("pressed", self, "_on_resume_pressed")
	settings.connect("pressed", self, "_on_settings_pressed")
	main_menu.connect("pressed", self, "_on_main_menu_pressed")
	
	var player = Global.game.player
	if player:
		player.connect("durability_changed", self, "_on_player_durability_changed")
		player.connect("ammo_changed", self, "_on_player_ammo_changed")
		Global.game.connect("score_changed", self, "_on_game_score_changed")
		
		durability_bar.value = player.durability
		score_bar.value = 0
		increase_score(0) # init call
		
		var max_rockets: int = PlayerBase.MAX_ROCKETS
		ammo_bar.max_value = max_rockets
		ammo_bar.value = max_rockets
		ammo_bar.stretch_margin_left = max_rockets * 4
	else:
		durability_bar.value = 0
		ammo_bar.visible = false
	
	if OS.has_touchscreen_ui_hint():
		touch_controls = Preloader.get_resource("TouchControls").instance()
		analog_controller = touch_controls.find_node("AnalogController")
		add_child(touch_controls)
	
	# the following settings are initially defined as visible in the editor
	gameover_caption.visible = false
	gameover_caption.modulate.a = 0.0
	flag_ru.visible = false
	flag_ua.visible = false
	statistics.visible = false
	pause_menu.visible = false

func set_durability(new_value: int) -> void:
	GlobalTween.stop(durability_bar)
	var difference = abs(durability_bar.value - new_value)
	GlobalTween.interpolate_property(durability_bar, "value", durability_bar.value, new_value, difference / 10.0)
	GlobalTween.start()

func increase_score(value: int) -> void:
	var progress = clamp(score_bar.value + value, 0, 100) / Global.victory_value * 100
	score_label.text = "Defense of Kyiv: %d%%" % progress
	var difference = abs(score_bar.value - progress)
	if difference:
		GlobalTween.stop(score_bar)
		GlobalTween.interpolate_property(score_bar, "value", score_bar.value, progress, difference / 10.0)
		GlobalTween.start()

func set_ammo(value: int) -> void:
	ammo_bar.value = value

func _on_game_pause_changed(state: bool) -> void:
	pause_menu.visible = state

func _on_player_durability_changed(value: int) -> void:
	set_durability(value)

func _on_player_ammo_changed(value: int) -> void:
	set_ammo(value)

func _on_game_score_changed(value: int) -> void:
	increase_score(value)

func _on_resume_pressed() -> void:
	Global.game.pause(false)

func _on_settings_pressed() -> void:
	pass

func _on_main_menu_pressed() -> void:
	Global.return_to_main_menu()
