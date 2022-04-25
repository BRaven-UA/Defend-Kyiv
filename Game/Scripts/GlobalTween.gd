extends Tween

const FLYING_TEXT_DURATION := 4.0
const PREVIEW_DURATION := 0.3
const PREVIEW_MIN_SCALE := Vector2(0.1, 0.1)


func _ready() -> void:
	playback_process_mode = TWEEN_PROCESS_PHYSICS

# basic show up animation
func show_up_preview(preview: Preview) -> void:
	interpolate_property(preview.frame, "scale", PREVIEW_MIN_SCALE, Vector2.ONE, PREVIEW_DURATION)
	start()

# basic fade animation (respecting current scale)
func fade_preview(preview: Preview) -> float:
	var _duration = preview.frame.scale.x * PREVIEW_DURATION
	interpolate_property(preview.frame, "scale", preview.scale, PREVIEW_MIN_SCALE, _duration)
	start()
	return _duration

func explosion_flash(flash: Sprite, scale: float) -> void:
	var duration = 0.01 * scale
	var brightness = 0.025 * scale
	interpolate_property(flash, "self_modulate:a", 0.0, brightness, duration, TRANS_EXPO, EASE_IN_OUT)
	interpolate_property(flash, "self_modulate:a", brightness, 0.0, duration, TRANS_SINE, EASE_IN_OUT, duration)
	start()

func explosion_shockwave(shockwave: Sprite, scale: float) -> void:
	shockwave.material.set_shader_param("force", 0.15 * scale)
	interpolate_property(shockwave, "material:shader_param/progression", 0.0, 3.0, 3.0)
	start()

func flying_text(node: Node2D) -> void:
	var _direction := Vector2.UP.rotated(Global.player.global_rotation)
	var _destination = node.global_position + _direction * 100
	interpolate_property(node, "global_position", node.global_position, _destination, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	interpolate_property(node, "scale", Vector2.ZERO, Vector2.ONE * 2.0, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	interpolate_property(node, "modulate:a", 0, 1, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	start()
