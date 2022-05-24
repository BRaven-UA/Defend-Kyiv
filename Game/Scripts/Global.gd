extends Node

enum RARITY {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const COLOR_NONE = Color.transparent
const COLOR_COMMON = Color.white
const COLOR_UNCOMMON = Color.green
const COLOR_RARE = Color.dodgerblue
const COLOR_EPIC = Color.blueviolet
const COLOR_LEGENDARY = Color.orange
const COLORS = [COLOR_NONE, COLOR_COMMON, COLOR_UNCOMMON, COLOR_RARE, COLOR_EPIC, COLOR_LEGENDARY]
const POINTS = [0, 1, 2, 4, 8, 16] # score points per rarity
const SHADOW := Vector2(0.707107, -0.707107) # normalized global shadow direction

var tree: SceneTree
var game: Game
var curve: Curve2D
var analog_controller: AnalogController
var debug: Debug
var viewport_size: Vector2
var score: int = 0


func _enter_tree() -> void:
	tree = get_tree()
	curve = Preloader.get_resource("MovePath2D")
	randomize()

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		analog_controller = AnalogController.new()
		add_child(analog_controller)

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			if OS.get_name() == "HTML5":
				JavaScript.eval("window.close()")
			else:
				quit()
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			# TODO: add pause when ingame
			quit()

func new_game() -> void:
	tree.change_scene_to(Preloader.get_resource("Game"))

func game_over() -> void:
	PoolManager.return_all_reusable()

func quit() -> void:
	# TODO: save game state
	tree.quit()

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
	var segment = PoolVector2Array([dest_rect.position, game.player.get_global_transform_with_canvas().origin])
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
	game.hud.set_score(score)

func pos_to_offset(pos: Vector2) -> float:
	return curve.get_closest_offset(pos)

