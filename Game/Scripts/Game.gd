class_name Game
extends Node2D

var tree: SceneTree
var places: Places # placeholders database
var viewport_size: Vector2

onready var ground_layer: Node2D = find_node("GroundLayer")
onready var above_ground_layer: Node2D = find_node("AboveGroundLayer")
onready var midair_layer: Node2D = find_node("MidairLayer")
onready var preview_layer: Node2D = find_node("PreviewLayer")
onready var path_follow: PathFollow2D = find_node("PathFollow")
onready var camera: Camera2D = find_node("Camera2D")
onready var player: PlayerBase = find_node("Player")
onready var information_layer: Node2D = find_node("InformationLayer")
onready var postprocess: BackBufferCopy = camera.find_node("Postprocess")
onready var hud: HUD = find_node("HUD")
onready var timer: Timer = find_node("Timer")


func _enter_tree() -> void:
	Global.game = self
	viewport_size = Global.viewport_size
	places = Preloader.get_resource("Places").duplicate()

func _ready() -> void:
	tree = get_tree()
	var screen_rect = camera.find_node("ScreenRectShape")
	screen_rect.shape.extents = viewport_size / 2
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	
	if OS.is_debug_build(): # only for debug purposes. Cuts off all groups that already behind player st the start of the game
		for index in places.groups.size():
			if places.groups[index].Offset < path_follow.offset:
				places.groups.resize(index)

func bump_camera() -> void:
	var shift = Vector2.ONE
	camera.offset += shift
	yield(tree.create_timer(0.05), "timeout")
	if camera.offset:
		camera.offset -= shift

func game_over() -> void:
	timer.stop()
	hud.warnings.visible = false
	postprocess.visible = true
	postprocess.update()
	var win = Global.score >= Global.VICTORY_VALUE
	GlobalTween.game_over(win)
	yield(tree.create_timer(GlobalTween.GAMEOVER_DURATION), "timeout")
	hud.anthem.stream = Preloader.get_resource("Ukraine Anthem" if win else "Russia Anthem")
	hud.anthem.play()
	PoolManager.return_all_reusable()

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
		# TODO: rewrite
		timer.stop()
		yield(tree.create_timer(viewport_size.y / path_follow.scroll_speed), "timeout")
		path_follow.set_scroll_speed(0)
	
	# back reusable objects behind
	var min_offset = offset - viewport_size.y * 2
	for node in tree.get_nodes_in_group(PoolManager.REUSABLE):
		if node.has_meta("Offset"):
			if node.get_meta("Offset") < min_offset:
				node.get_parent().remove_child(node) # back to an object pool

func _on_timer_timeout() -> void:
	_routine()
