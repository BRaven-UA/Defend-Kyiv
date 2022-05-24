# TextureProgress fits much better here, but there is a bug: radial mode does not work properly with TextureAtlas
class_name RadialIndicator
extends Node2D

enum {OUTER_FIRST_FRAME = 2, INNER_FIRST_FRAME = 13}
const TICKS := 10.0

onready var outer_shadow: Sprite = find_node("OuterShadow")
onready var inner_shadow: Sprite = find_node("InnerShadow")
onready var outer_progress: Sprite = find_node("OuterProgress")
onready var inner_progress: Sprite = find_node("InnerProgress")
onready var outer_timer: Timer = find_node("OuterTimer")
onready var inner_timer: Timer = find_node("InnerTimer")


func _ready() -> void:
	set_process(false)
	inner_timer.connect("timeout", self, "_on_timer_timeout", [inner_timer, inner_progress, INNER_FIRST_FRAME])
	outer_timer.connect("timeout", self, "_on_timer_timeout", [outer_timer, outer_progress, OUTER_FIRST_FRAME])

func _process(delta: float) -> void:
	global_rotation = Global.game.player.global_rotation

func activate(inner_state: bool, outer_state: bool) -> void:
	set_process(Global.game.player != null)
	inner_shadow.visible = inner_state
	inner_progress.visible = inner_state
	outer_shadow.visible = outer_state
	outer_progress.visible = outer_state

func deactivate() -> void:
	inner_timer.stop()
	outer_timer.stop()
	set_process(false)
	visible = false

func start_inner_progress(max_value: float, init_value := 0.0) -> void:
	_start_progress(max_value, init_value, inner_progress, INNER_FIRST_FRAME, inner_timer)

func start_outer_progress(max_value: float, init_value := 0.0) -> void:
	_start_progress(max_value, init_value, outer_progress, OUTER_FIRST_FRAME, outer_timer)

func _start_progress(max_value: float, init_value: float, progress: Sprite, first_frame: int, timer: Timer) -> void:
	if max_value > 0.0 and init_value < max_value:
		var interval: float = max_value / TICKS
		progress.frame = first_frame + int(init_value / interval)
		timer.wait_time = interval
		timer.start()

func _on_timer_timeout(timer: Timer, progress: Sprite, first_frame: int) -> void:
	progress.frame += 1
	if progress.frame < first_frame + TICKS:
		timer.start()
