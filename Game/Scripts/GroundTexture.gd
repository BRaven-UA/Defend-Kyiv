extends Sprite

const z = Vector2.ZERO
const wave_positions =[z, z, z, z, z, z, z, z, z]
const crater_positions = [z, z, z, z, z, z, z, z, z, z, z, z, z, z, z, z, z, z, z, z]
var current_wave_index := 0
var current_crater_index := 0


func _process(delta: float) -> void:
	var rotated_pos = global_position.rotated(-global_rotation)
	var screen_origin = rotated_pos - Global.viewport_size / 2.0
	# shift all shader positions on screen
	for index in crater_positions.size():
		var shader_pos = _get_shader_pos(crater_positions[index], screen_origin)
		material.set_shader_param("crater_pos%d" % index, shader_pos)
	for index in wave_positions.size():
		var shader_pos = _get_shader_pos(wave_positions[index], screen_origin)
		material.set_shader_param("wave_pos%d" % index, shader_pos)

func _get_shader_pos(target_pos: Vector2, screen_origin: Vector2) -> Vector2: # both positions in global coords
	var rotated_target_pos = target_pos.rotated(-global_rotation)
	return (rotated_target_pos - screen_origin) / Global.viewport_size

func start_wave(target_pos: Vector2): # position in global coords
	wave_positions[current_wave_index] = target_pos
	var property = "shader_param/wave_size%d" % current_wave_index
	GlobalTween.interpolate_property(material, property, 0.0, 1.0, 1.0)
	GlobalTween.start()
	current_wave_index = (current_wave_index + 1) % 9 # cycle through range from 0 to 8

func place_crater(target_pos: Vector2): # position in global coords
	crater_positions[current_crater_index] = target_pos
	current_crater_index = (current_crater_index + 1) % 20 # cycle through range from 0 to 19
