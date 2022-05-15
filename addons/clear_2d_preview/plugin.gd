tool
extends EditorPlugin

var canvas_menu: HBoxContainer
var button: ToolButton
var canvas_viewport


func _enter_tree() -> void:
	# getting all nodes below editor viewport
	var editor_nodes = _get_all_nodes(get_editor_interface().get_editor_viewport())
	
	# searching for two specific classes
	for node in editor_nodes:
		if node.get_class() == "CanvasItemEditor":
			canvas_menu = node.get_child(0)
		if node.get_class() == "CanvasItemEditorViewport":
			canvas_viewport = node
			break
	
	# if there is 2D editor, add preview button
	if canvas_viewport:
		button = ToolButton.new()
		button.text = "Preview"
		button.toggle_mode = true
		canvas_menu.add_child(button)
		button.connect("toggled", self, "_on_button_toggled")

func _exit_tree() -> void:
	# remove the button and make sure the canvas is visible
	if canvas_viewport:
		_transparent_canvas(false)
		button.disconnect("toggled", self, "_on_button_toggled")
		canvas_menu.remove_child(button)
		button.free()

# toggle visibility (via opacity) of the canvas
# (hiding via visible property also disables input control, which is unacceptable)
func _transparent_canvas(state: bool) -> void:
	canvas_viewport.self_modulate.a = float(!state)

# return an array of all children of the given node and their children recursively
func _get_all_nodes(root: Node, list = []):
	for node in root.get_children():
		list.append(node)
		_get_all_nodes(node, list)
	return list

# button callback that toggles canvas visibility
func _on_button_toggled(state: bool) -> void:
	_transparent_canvas(state)
