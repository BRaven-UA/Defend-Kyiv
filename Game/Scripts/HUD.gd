class_name HUD
extends CanvasLayer

onready var base: Control = $BaseControl
onready var ammo_bar: TextureProgress = base.find_node("AmmoBar")
onready var score: Label = base.find_node("Score")
onready var warnings: Control = base.find_node("Warnings")


func _enter_tree() -> void:
	Global.hud = self # register itself in global singleton

func _ready() -> void:
	if OS.is_debug_build(): # not available in release build
		base.add_child(load("res://Debug/Debug.tscn").instance())
	
	if Global.player:
		var max_rockets: int = Global.player.MAX_ROCKETS
		ammo_bar.max_value = max_rockets
		ammo_bar.value = max_rockets
		ammo_bar.stretch_margin_left = max_rockets * 4
	else:
		ammo_bar.visible = false

func set_score(value: int) -> void:
	score.text = "Score: %d" % value

func set_ammo(value: int) -> void:
	ammo_bar.value = value
