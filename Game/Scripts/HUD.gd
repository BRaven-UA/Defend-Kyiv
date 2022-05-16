class_name HUD
extends CanvasLayer

onready var base: Control = $BaseControl
onready var health_bar: ProgressBar = base.find_node("HealthBar")
onready var ammo_bar: TextureProgress = base.find_node("AmmoBar")
onready var score: Label = base.find_node("Score")
onready var warnings: Control = base.find_node("Warnings")


func _enter_tree() -> void:
	Global.hud = self # register itself in global singleton

func _ready() -> void:
	if OS.is_debug_build(): # not available in release build
		base.add_child(load("res://Debug/Debug.tscn").instance())
	
	var player = Global.player
	if player:
		player.connect("health_changed", self, "set_health")
		player.connect("ammo_changed", self, "set_ammo")
		
		health_bar.value = player.health
		
		var max_rockets: int = player.MAX_ROCKETS
		ammo_bar.max_value = max_rockets
		ammo_bar.value = max_rockets
		ammo_bar.stretch_margin_left = max_rockets * 4
	else:
		health_bar.value = 0
		ammo_bar.visible = false

func set_health(new_value: int) -> void:
	GlobalTween.stop(health_bar)
	var difference = abs(health_bar.value - new_value)
	if difference > 1:
		GlobalTween.interpolate_property(health_bar, "value", health_bar.value, new_value, difference / 10.0)

func set_score(value: int) -> void:
	score.text = "Score: %d" % value

func set_ammo(value: int) -> void:
	ammo_bar.value = value
