class_name WarningSign
extends TextureRect

var target: Node2D
onready var mark: TextureRect = find_node("WarningMark")


func _process(delta: float) -> void:
	rect_global_position = target.get_global_transform_with_canvas().origin - rect_size / 2.0
	var pos = Global.clamp_to_screen(get_global_rect())
	mark.visible = rect_global_position != pos
	rect_global_position = pos

func activate(_target: Node2D) -> void:
	if _target:
		Global.game.hud.warnings.add_child(self)
		target = _target
#		visible = true
		set_process(true)

func deactivate() -> void:
#	set_process(false)
#	target = null
#	visible = false
	get_parent().remove_child(self)
