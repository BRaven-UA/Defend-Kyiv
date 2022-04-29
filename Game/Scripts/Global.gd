extends Node

enum RARITY {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const COLOR_NONE = Color.transparent
const COLOR_COMMON = Color.white
const COLOR_UNCOMMON = Color.green
const COLOR_RARE = Color.dodgerblue
const COLOR_EPIC = Color.blueviolet
const COLOR_LEGENDARY = Color.orange
const COLOR = [COLOR_NONE, COLOR_COMMON, COLOR_UNCOMMON, COLOR_RARE, COLOR_EPIC, COLOR_LEGENDARY]
const POINTS = [0, 1, 2, 4, 8, 16] # score points per rarity
const SHADOW := Vector2(0.707107, -0.707107) # normalized global shadow direction
#const Player = preload("res://Game/Scripts/Player.gd")
#const Rocket = preload("res://Game/Scripts/Rocket.gd")

var viewport_size: Vector2 # set by player node
var score: int = 0

# reference pool
var main: Node2D
var path_follow: PathFollow2D
var player: PlayerBase
var analog_controller: AnalogController
var hud: HUD
var debug: Debug

onready var ground_layer: Node2D = main.find_node("GroundLayer")
onready var above_ground_layer: Node2D = main.find_node("AboveGroundLayer")
onready var midair_layer: Node2D = main.find_node("MidairLayer")
onready var preview_layer: Node2D = main.find_node("PreviewLayer")
onready var flying_text_layer: Node2D = main.find_node("FlyingTextLayer")
onready var default_font = Preloader.get_resource("Theme").default_font

func _enter_tree() -> void:
	main = get_tree().current_scene
	randomize()

func clamp_int(value: int, min_value: int, max_value: int) -> int:
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value

func increase_score(value: int) -> void:
	assert(value > 0)
	score += value
	hud.set_score(score)
