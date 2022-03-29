extends Node

const COLOR_NONE = Color.transparent
const COLOR_COMMON = Color.white
const COLOR_UNCOMMON = Color.green
const COLOR_RARE = Color.dodgerblue
const COLOR_EPIC = Color.blueviolet
const COLOR_LEGENDARY = Color.orange
enum RARITY {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const COLOR = [COLOR_NONE, COLOR_COMMON, COLOR_UNCOMMON, COLOR_RARE, COLOR_EPIC, COLOR_LEGENDARY]
const POINTS = [0, 1, 2, 4, 8, 16] # score points per rarity
const SHADOW := Vector2(0.707107, -0.707107) # normalized global shadow direction

# reference pool
var main: Node2D
onready var ground_layer: Node2D = main.find_node("GroundLayer")
onready var midair_layer: Node2D = main.find_node("MidairLayer")
onready var preview_layer: Node2D = main.find_node("PreviewLayer")
onready var flying_text_layer: Node2D = main.find_node("FlyingTextLayer")
var path_follow: PathFollow2D
var player: Player
var analog_controller: AnalogController
var hud: HUD

var viewport_size: Vector2 # set by player node
onready var default_font = Preloader.get_resource("Theme").default_font
var score: int = 0

func _enter_tree() -> void:
	main = get_tree().current_scene
	randomize()

func increase_score(value: int) -> void:
	assert(value > 0)
	score += value
	hud.set_score(score)
