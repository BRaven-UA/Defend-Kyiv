tool
extends EditorPlugin

var canvas_editor
var canvas_menu: HBoxContainer
var button: ToolButton
var canvas_viewport


func _enter_tree() -> void:
	var editor_nodes = _get_all_nodes(get_editor_interface().get_editor_viewport())
	
	for node in editor_nodes:
		if node.get_class() == "CanvasItemEditor":
			canvas_editor = node
			canvas_menu = node.get_child(0)
		if node.get_class() == "CanvasItemEditorViewport":
			canvas_viewport = node
			break
	
	if canvas_viewport:
		button = ToolButton.new()
		button.text = "Preview"
		button.toggle_mode = true
		canvas_menu.add_child(button)
		button.connect("toggled", self, "_on_button_toggled")

func _exit_tree() -> void:
	if canvas_viewport:
#		canvas_viewport.visible = true
		_transparent_canvas(false)
		button.disconnect("toggled", self, "_on_button_toggled")
		canvas_menu.remove_child(button)
		button.free()

func _transparent_canvas(state: bool) -> void:
	canvas_viewport.self_modulate.a = float(!state)

func _get_all_nodes(root: Node, list = []):
	for node in root.get_children():
		list.append(node)
		_get_all_nodes(node, list)
	return list

func _on_button_toggled(state: bool) -> void:
#	canvas_viewport.visible = !state
	_transparent_canvas(state)
