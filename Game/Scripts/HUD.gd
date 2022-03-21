extends CanvasLayer

class_name HUD

onready var score: Label = find_node("Score")
onready var debug_label_1: Label = find_node("DebugLabel_1")
onready var debug_label_2: Label = find_node("DebugLabel_2")


func _enter_tree() -> void:
	Global.hud = self # register itself in global singleton

func set_score(value: int) -> void:
	score.text = "Score: %d" % value
