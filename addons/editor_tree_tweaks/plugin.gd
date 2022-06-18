tool
extends EditorPlugin

var tweaked_nodes: Array

func _enter_tree() -> void:
	# getting all nodes of editor interface
	var editor_nodes = _get_all_nodes(get_editor_interface().get_base_control())
	
	# searching for specific class and tweak it
	for node in editor_nodes:
		if node is Tree:
			tweaked_nodes.append(node) # store for later rollback
			node.set("custom_constants/item_margin", 10)
			node.set("custom_constants/vseparation", 0)

func _exit_tree() -> void:
	# restoring default values
	for node in tweaked_nodes:
		node.set("custom_constants/item_margin", 12)
		node.set("custom_constants/vseparation", 4)
	tweaked_nodes.clear()

# return an array of all children of the given node and their children recursively
func _get_all_nodes(root: Node, list = []):
	for node in root.get_children():
		list.append(node)
		_get_all_nodes(node, list)
	return list
