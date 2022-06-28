extends PathFollow2D

var scroll_speed := 50.0 # per second
onready var start_offset := offset


func _enter_tree() -> void:
	get_parent().visible = true # the parent may be hidden in the editor due to Path2D performance issues
	match Global.game_mode:
		Global.GAMEMODE.DEBUG:
			offset = 125000.0
		Global.GAMEMODE.DEMO:
			offset = 111000.0
		_:
			offset = 0.0


func _process(delta: float) -> void:
	# constantly move along the path
	offset += delta * scroll_speed

func reset_position() -> void:
	offset = start_offset

func set_scroll_speed(value: float) -> void:
	scroll_speed = value
	set_process(value as bool)
