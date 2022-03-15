extends Node

# reference pool
var main: Node2D
var Path_Follow: PathFollow2D
var analog_controller: AnalogController
var debug_label_1: Label
var debug_label_2: Label


func _enter_tree() -> void:
	main = get_tree().current_scene
