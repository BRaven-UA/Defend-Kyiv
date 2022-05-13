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
const REUSABLE := "Reusable" # name of the node group for nodes that can be reused

var viewport_size: Vector2
var score: int = 0

# reference pool
var tree: SceneTree
var main: Node2D
var places: Places # placeholders database
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
onready var timer: Timer = Timer.new()
onready var curve: Curve2D = Preloader.get_resource("MovePath2D")

func _enter_tree() -> void:
	tree = get_tree()
	main = tree.current_scene
	places = Preloader.get_resource("Places")
	randomize()

func _ready() -> void:
	viewport_size = main.get_viewport_rect().size
	var _screen_rect = camera.find_node("ScreenRectShape")
	_screen_rect.shape.extents = viewport_size / 2
	
	if path_follow:
		timer.connect("timeout", self, "_on_timer_timeout")
		add_child(timer)
		timer.start()
	
	if OS.is_debug_build(): # only for debug purposes. Cuts off all groups that already behind player st the start of the game
		for index in places.groups.size():
			if places.groups[index].Offset < path_follow.offset:
				places.groups.resize(index)

func clamp_int(value: int, min_value: int, max_value: int) -> int:
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value

# simple clamp given rectangle position to match screen rectangle
func match_screen(rect: Rect2) -> Vector2:
	var screen_size = viewport_size - rect.size
	var x = clamp(rect.position.x, 0, screen_size.x)
	var y = clamp(rect.position.y, 0, screen_size.y)
	return Vector2(x, y)

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

func pos_to_offset(pos: Vector2) -> float:
	return curve.get_closest_offset(pos)

# called periodically during the game (by default every second)
func _routine() -> void:
	var offset = path_follow.offset
	
	# spawn enemies before
	if places.groups:
		var group_data = places.groups.back() # groups must be sorted by offset in descending order
		var max_offset = offset + viewport_size.y * 2
		if group_data.Offset < max_offset:
			EnemyManager.spawn_enemy_group(group_data)
			places.groups.resize(places.groups.size() - 1)
	else: # end of map
		timer.stop()
		yield(tree.create_timer(viewport_size.y / path_follow.scroll_speed), "timeout")
		path_follow.set_scroll_speed(0)
	
	# back reusable objects behind
	var min_offset = offset - viewport_size.y * 2
	for node in tree.get_nodes_in_group(REUSABLE):
		if node.get_meta("Offset") < min_offset:
			node.get_parent().remove_child(node) # back to an object pool

func _on_timer_timeout() -> void:
	_routine()
