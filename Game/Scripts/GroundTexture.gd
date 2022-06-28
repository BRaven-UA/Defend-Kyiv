extends Sprite

var waves =[true, true, true, true, true, true, true, true, true]
var current_crater := 1
var start_position: Vector2
#var shader_offset: Vector2


func _ready() -> void:
	start_position = global_position.rotated(-global_rotation)
	GlobalTween.connect("tween_completed", self, "_on_tween_completed")

#func _input(event: InputEvent) -> void:
#	if event is InputEventScreenTouch:
#		if event.pressed:
#			start_wave(event.position)

func _process(delta: float) -> void:
	var rotated_pos = global_position.rotated(-global_rotation)
	var delta_pos = (rotated_pos - start_position) / Global.viewport_size
	material.set_shader_param("delta_pos", delta_pos)
	if Input.is_action_pressed("ui_accept"):
		print(delta_pos)

func start_wave(target_pos: Vector2): # position in global coords
	var index = waves.find(true) + 1
	if index:
		waves[index - 1] = false
		material.set_shader_param("wave_pos%d" % index, _get_shader_pos(target_pos))
		var property = "shader_param/wave_size%d" % index
		GlobalTween.interpolate_property(material, property, 0.0, 1.0, 1.0)
		GlobalTween.start()

func place_crater(target_pos: Vector2): # position in global coords
	material.set_shader_param("crater_pos%d" % current_crater, _get_shader_pos(target_pos))
	current_crater = current_crater % 16 + 1 # cycle through range from 1 to 16

func _get_shader_pos(target_pos: Vector2) -> Vector2: # position in global coords
	var rotated_pos = global_position.rotated(-global_rotation)
	var rotated_target_pos = target_pos.rotated(-global_rotation)
	var screen_origin = rotated_pos - Global.viewport_size / 2.0
	return (rotated_target_pos - screen_origin) / Global.viewport_size

func _on_tween_completed(object: Object, key: NodePath):
	var subname = key.get_subname(0)
	var index: int = subname[subname.length() - 1] as int
	waves[index - 1] = true
