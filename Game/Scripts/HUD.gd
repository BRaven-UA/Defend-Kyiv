extends CanvasLayer

class_name HUD

onready var score: Label = find_node("Score")
onready var debug_panel: VBoxContainer = find_node("DebugPanel")
onready var debug_label_1: Label = find_node("DebugLabel_1")
onready var debug_label_2: Label = find_node("DebugLabel_2")


func _enter_tree() -> void:
	Global.hud = self # register itself in global singleton

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_panel"):
		debug_panel()

func set_score(value: int) -> void:
	score.text = "Score: %d" % value

func debug_panel(state: int = -1): # three state workaround: 0 - false, 1 - true, -1 - toggle
	var _visible: bool
	if state == -1: # toggle by default
		_visible = !debug_panel.visible
	else:
		_visible = state as bool # type casting
	debug_panel.visible = _visible
