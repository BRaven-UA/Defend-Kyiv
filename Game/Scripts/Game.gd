class_name Game
extends Node2D

signal score_changed

var tree: SceneTree
var places: Places # placeholders database
var viewport_size: Vector2
var score: int

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

func increase_score(value: int) -> void:
	score += value
	emit_signal("score_changed", value)

func game_over() -> void:
	timer.stop()
	if hud.touch_controls:
		hud.touch_controls.visible = false
	hud.warnings.visible = false
	postprocess.visible = true
	postprocess.update()
	
	hud.total_score.text = "Total score: %d" % score
	if score:
		for enemy_data in EnemyManager.ENEMIES:
			if enemy_data[EnemyManager.DESTROYED]:
				var stat_unit = Preloader.get_resource("StatisticUnit").instance()
				hud.statistic_units.add_child(stat_unit)
				stat_unit.init(enemy_data)
	
	var win = score >= Global.VICTORY_VALUE
	hud.gameover_caption.text = "SUCCESS !\nKyiv is defended" if win else "FAILURE !\nKyiv is occupied"
	GlobalTween.game_over(win)
	
	yield(tree.create_timer(GlobalTween.GAMEOVER_DURATION), "timeout")
	var flag = hud.flag_ua if win else hud.flag_ru
	hud.flag.visible = true
	hud.gameover_caption.visible = true
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
