extends Tween

const FLYING_TEXT_DURATION := 4.0
const PREVIEW_DURATION := 0.3
const GAMEOVER_DURATION := 3.0

onready var noise = OpenSimplexNoise.new()


func _ready() -> void:
#	playback_process_mode = TWEEN_PROCESS_PHYSICS
	noise.period = 2

# basic show up animation
func show_up_preview(frame: Node2D) -> void:
	stop(frame) # stop all preview animations
	interpolate_property(frame, "scale", Vector2.ZERO, Vector2.ONE, PREVIEW_DURATION)
	start()

# basic fade animation (respecting current scale)
func fade_preview(frame: Node2D) -> void:
	stop(frame) # stop all preview animations
	var duration = frame.scale.x * PREVIEW_DURATION
	interpolate_property(frame, "scale", frame.scale, Vector2.ZERO, duration)
	start()

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
	var _direction := Vector2.UP.rotated(Global.game.player.global_rotation)
	var _destination = node.global_position + _direction * 100
	interpolate_property(node, "global_position", node.global_position, _destination, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	interpolate_property(node, "scale", Vector2.ZERO, Vector2.ONE * 2.0, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	interpolate_property(node, "modulate:a", 0, 1, FLYING_TEXT_DURATION, TRANS_EXPO, EASE_OUT)
	start()

func start_breakdown(player: PlayerBase) -> void:
	interpolate_property(player, "engine_efficiency", 1.0, 0.5, 3.0)
	start()

func cancel_breakdown(player: PlayerBase) -> void:
	interpolate_property(player, "engine_efficiency", 0.5, 1.0, 3.0)
	start()

func shake_camera() -> void:
	if Global.game.camera:
		noise.seed = randi()
		interpolate_method(self, "_shake_camera_process", 0, 60, 0.5)
		start()

func game_over(win: bool) -> void:
	var direction = Vector2.UP if win else Vector2.DOWN
	interpolate_property(Global.game.player, "direction", Global.game.player.direction, direction, GAMEOVER_DURATION)
	interpolate_property(Global.game.path_follow, "scroll_speed", Global.game.path_follow.scroll_speed, 0, GAMEOVER_DURATION)
	interpolate_property(Global.game.postprocess, "material:shader_param/blur", 0.0, 2.0, 2.0)
	interpolate_method(Global, "set_battlefield_volume", 0, -80, GAMEOVER_DURATION)
	
	var flag = Global.game.hud.flag_ua if win else Global.game.hud.flag_ru
	var start = Global.viewport_size.y if win else 0.0
	interpolate_property(flag, "rect_position:y", start, flag.rect_position.y, GAMEOVER_DURATION, TRANS_SINE, EASE_OUT, GAMEOVER_DURATION)
	
	interpolate_property(Global.game.hud.gameover_caption, "modulate:a", 0, 1, 0.5, TRANS_LINEAR, EASE_IN_OUT, GAMEOVER_DURATION * 2)
	interpolate_property(Global.game.hud.statistics, "rect_position:y", Global.viewport_size.y, Global.game.hud.statistics.rect_position.y, GAMEOVER_DURATION, TRANS_SINE, EASE_OUT, GAMEOVER_DURATION * 2)
	Global.game.hud.statistics.rect_position.y = Global.viewport_size.y
	Global.game.hud.statistics.visible = true
	
	start()

func _shake_camera_process(delta: float):
	var strength = lerp(60.0 - delta, 0.0, 0.05)
	var noise_point = Vector2(noise.get_noise_2d(1, delta), noise.get_noise_2d(100, delta))
	Global.game.camera.offset = noise_point * strength
	var color_value = 1.0 - (noise_point.length() if strength > 0.05 else 0.0)
	Global.game.background.modulate = Color(1.0, color_value, color_value, 1.0)
