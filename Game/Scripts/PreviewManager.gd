extends Tween

const DURATION := 0.3
const MIN_SCALE := Vector2(0.1, 0.1)
const EMPTY_PATH := NodePath("")

onready var scene_tree: SceneTree = get_tree()
var preview_pool: Array # object pool for preview


func _ready() -> void:
	playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS

func get_preview() -> Preview:
	for preview in preview_pool: # search for free preview
		if not preview.visible:
			return preview
	
	# add new instance to the pool if there no free preview left
	var new_preview: Preview = Preloader.get_resource("Preview").instance()
	preview_pool.append(new_preview)
	Global.preview_layer.add_child(new_preview)
	return new_preview

func activate_preview(pos: Vector2, texture: Texture, color: Color) -> Preview:
	var preview: Preview = get_preview()
	preview.activate(pos, texture, color)
	# add basic show up animation
	interpolate_property(preview.frame, "scale", MIN_SCALE, Vector2.ONE, DURATION)
	start()
	return preview

func deactivate_preview(preview: Preview) -> void:
	# add basic fade animation (respecting current scale)
	var _duration = preview.scale.x * DURATION
	interpolate_property(preview.frame, "scale", preview.scale, MIN_SCALE, _duration)
	start()
	# waiting for the end of animation and return the preview back to the pool
	yield(scene_tree.create_timer(_duration), "timeout")
	preview.deactivate()
