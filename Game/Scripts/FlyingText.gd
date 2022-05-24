class_name FlyingText
extends Node2D

var text: String
var color: Color


func _process(delta: float) -> void:
	global_rotation = Global.game.player.global_rotation

func _draw() -> void:
	var size = GUI.default_font.get_string_size(text)
	draw_string(GUI.default_font, Vector2(-size.x / 2.0, 0), text, color)

func activate(_text: String, _color := Color(1, 1, 1, 1), pos := Vector2.ZERO) -> void:
	if Global.game.player and Global.game.flying_text_layer:
		global_position = pos
		Global.game.flying_text_layer.add_child(self)
		text = _text
		color = _color
		GlobalTween.flying_text(self)
		update()
		# wait until the animation ends
		yield(get_tree().create_timer(GlobalTween.FLYING_TEXT_DURATION), "timeout")
		deactivate()

func deactivate() -> void:
	get_parent().remove_child(self)
