# template to any temporary debug nodes
extends Node


func _enter_tree() -> void:
	Global.set(name, self) # register itself in global singleton
