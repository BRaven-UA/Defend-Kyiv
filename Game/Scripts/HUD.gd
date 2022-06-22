class_name HUD
extends CanvasLayer

var touch_controls: Node2D
var analog_controller: AnalogController
onready var base: Control = $BaseControl
onready var durability_bar: ProgressBar = base.find_node("DurabilityBar")
onready var ammo_bar: TextureProgress = base.find_node("AmmoBar")
onready var flares_bar: ProgressBar = base.find_node("FlaresBar")
onready var flares_label: Label = base.find_node("FlaresLabel")
onready var score_bar: ProgressBar = base.find_node("ScoreBar")
onready var score_label: Label = base.find_node("ScoreLabel")

onready var warnings: Control = base.find_node("Warnings")
onready var gameover_caption: Label = base.find_node("GameoverCaption")
onready var flag_ru: ColorRect = base.find_node("FlagRU")
onready var flag_ua: ColorRect = base.find_node("FlagUA")
onready var statistics: PanelContainer = base.find_node("Statistics")
onready var statistic_units: GridContainer = base.find_node("StatisticUnits")
onready var honor_points: Label = base.find_node("HonorPoints")

onready var pause_menu: Panel = base.find_node("PauseMenu")
onready var resume_button: Button = pause_menu.find_node("ResumeButton")
onready var settings_button: Button = pause_menu.find_node("SettingsButton")
onready var main_menu_button: Button = pause_menu.find_node("MainMenuButton")

onready var settings: PanelContainer = base.find_node("Settings")
onready var volume_slider: HSlider = settings.find_node("Volume").get_node("HSlider")
onready var brightness_slider: HSlider = settings.find_node("Brightness").get_node("HSlider")
onready var contrast_slider: HSlider = settings.find_node("Contrast").get_node("HSlider")
onready var saturation_slider: HSlider = settings.find_node("Saturation").get_node("HSlider")
onready var settings_reset_button: Button = settings.find_node("Reset")
onready var settings_close_button: Button = settings.find_node("Close")

onready var anthem: AudioStreamPlayer = base.find_node("Anthem")
onready var background_color_shader: ShaderMaterial = Preloader.get_resource("ColorManipulator")


func _enter_tree() -> void:
	Global.game.hud = self # register itself in global singleton

func _ready() -> void:
	Global.config.connect("settings_changed", self, "_on_config_settings_changed")
	Global.game.connect("pause_changed", self, "_on_game_pause_changed")
	resume_button.connect("pressed", self, "_on_resume_button_pressed")
	settings_button.connect("pressed", self, "_on_settings_button_pressed")
	main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
	volume_slider.connect("value_changed", self, "_on_volume_slider_value_changed")
	brightness_slider.connect("value_changed", self, "_on_brightness_slider_value_changed")
	contrast_slider.connect("value_changed", self, "_on_contrast_slider_value_changed")
	saturation_slider.connect("value_changed", self, "_on_saturation_slider_value_changed")
	settings_reset_button.connect("pressed", self, "_on_settings_reset_button_pressed")
	settings_close_button.connect("pressed", self, "_on_settings_close_button_pressed")
	
	var player = Global.game.player
	if player:
		player.connect("durability_changed", self, "_on_player_durability_changed")
		player.connect("ammo_changed", self, "_on_player_ammo_changed")
		player.connect("flares_used", self, "_on_player_flares_used")
		Global.game.connect("score_changed", self, "_on_game_score_changed")
		
		durability_bar.value = player.durability
		flares_bar.max_value = PlayerBase.FLARES_COOLDOWN
		flares_bar.value = PlayerBase.FLARES_COOLDOWN
		score_bar.value = 0
		increase_score(0) # init call
		restore_settings()
		
		var max_rockets: int = PlayerBase.MAX_ROCKETS
		ammo_bar.max_value = max_rockets
		ammo_bar.value = max_rockets
		ammo_bar.stretch_margin_left = max_rockets * 4
	else:
		durability_bar.value = 0
		ammo_bar.visible = false
	
	var is_flares_installed = Global.config.upgrades["FLARES"] as bool
	flares_bar.visible = is_flares_installed
	flares_label.visible = is_flares_installed
	restore_settings()
	
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
	settings.visible = false
	pause_menu.visible = false

func set_durability(new_value: int) -> void:
	GlobalTween.stop(durability_bar)
	var difference = abs(durability_bar.value - new_value)
	GlobalTween.interpolate_property(durability_bar, "value", durability_bar.value, new_value, difference / 10.0)
	GlobalTween.start()

func start_flares_cooldown() -> void:
	GlobalTween.interpolate_property(flares_bar, "value", 0.0, PlayerBase.FLARES_COOLDOWN, PlayerBase.FLARES_COOLDOWN)
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

func restore_settings() -> void:
	volume_slider.value = Global.config.volume
	brightness_slider.value = Global.config.brightness
	contrast_slider.value = Global.config.contrast
	saturation_slider.value = Global.config.saturation

func _on_config_settings_changed() -> void:
	restore_settings()

func _on_game_pause_changed(state: bool) -> void:
	pause_menu.visible = state
	if state:
		pause_menu.grab_focus()

func _on_player_durability_changed(value: int) -> void:
	set_durability(value)

func _on_player_ammo_changed(value: int) -> void:
	set_ammo(value)

func _on_player_flares_used(flares: Array) -> void:
	start_flares_cooldown()

func _on_game_score_changed(value: int) -> void:
	increase_score(value)

func _on_resume_button_pressed() -> void:
	Global.game.pause(false)

func _on_settings_button_pressed() -> void:
	settings.visible = true
	settings.grab_focus()

func _on_main_menu_button_pressed() -> void:
	Global.return_to_main_menu()

func _on_volume_slider_value_changed(value: float) -> void:
	Global.config.volume = value
	AudioServer.set_bus_volume_db(0, linear2db(value))

func _on_brightness_slider_value_changed(value: float) -> void:
	Global.config.brightness = value
	background_color_shader.set_shader_param("brightness", value)

func _on_contrast_slider_value_changed(value: float) -> void:
	Global.config.contrast = value
	background_color_shader.set_shader_param("contrast", value)

func _on_saturation_slider_value_changed(value: float) -> void:
	Global.config.saturation = value
	background_color_shader.set_shader_param("saturation", value)

func _on_settings_reset_button_pressed() -> void:
	Global.config.reset_settings()

func _on_settings_close_button_pressed() -> void:
	Global.config.save()
	settings.visible = false
	if pause_menu.visible:
		pause_menu.grab_focus()
