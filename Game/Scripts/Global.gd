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

var viewport_size: Vector2
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
onready var camera: Camera2D = main.find_node("Camera2D")
onready var default_font = Preloader.get_resource("Theme").default_font
onready var screen_rect = get_viewport().get_visible_rect()

func _enter_tree() -> void:
	main = get_tree().current_scene
	randomize()

func _ready() -> void:
	viewport_size = main.get_viewport_rect().size

func clamp_int(value: int, min_value: int, max_value: int) -> int:
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value

#func match_screen(rect: Rect2) -> Vector2:
#	var screen_size = viewport_size - rect.size
#	var x = clamp(rect.position.x, 0, screen_size.x)
#	var y = clamp(rect.position.y, 0, screen_size.y)
#	return Vector2(x, y)

# Return adjusted position of given rectangle to fit screen boundaries. Used in offscreen indicators. Both the argument and returned value in global screen coordinates
func clamp_to_screen(dest_rect: Rect2) -> Vector2:
	# shrink screen area to make sure given rectangle will be visible
	var screen_size = viewport_size - dest_rect.size
	
	# define trajectory segment and screen polygon
	var segment = PoolVector2Array([dest_rect.position, Global.player.get_global_transform_with_canvas().origin])
	var screen_polygon = PoolVector2Array([Vector2.ZERO, Vector2(screen_size.x, 0), screen_size, Vector2(0, screen_size.y)])
	
	# cutoff the trajectory with screen polygon
	var remainder: Array = Geometry.clip_polyline_with_polygon_2d(segment, screen_polygon)
	if remainder: # given rectangle is offscreen
		return remainder[0][1] # return intersection point
	else:
		return dest_rect.position # return original position with no changes

func increase_score(value: int) -> void:
	assert(value > 0)
	score += value
	hud.set_score(score)
