extends CanvasLayer

class_name HUD

onready var base: Control = $BaseControl
onready var score: Label = base.find_node("Score")


func _enter_tree() -> void:
	Global.hud = self # register itself in global singleton

func _ready() -> void:
	if OS.is_debug_build(): # not available in release build
		base.add_child(load("res://Debug/Debug.tscn").instance())

func set_score(value: int) -> void:
	score.text = "Score: %d" % value

