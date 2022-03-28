extends Node2D

var area = preload("res://Temp/Rigid2D+Joint.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var area_inst = area.instance()
		area_inst.global_position = get_global_mouse_position()
		add_child(area_inst)
