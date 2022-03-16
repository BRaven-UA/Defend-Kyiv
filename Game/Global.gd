extends Node

# reference pool
var main: Node2D
var midair_layer: Node2D
var ground_layer: Node2D
var path_follow: PathFollow2D
var player: Player
var analog_controller: AnalogController
var debug_label_1: Label
var debug_label_2: Label


func _enter_tree() -> void:
	main = get_tree().current_scene

func _ready() -> void:
	midair_layer = main.find_node("MidairLayer")
	ground_layer = main.find_node("GroundLayer")
	
	randomize()
