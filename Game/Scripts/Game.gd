class_name Game
extends Node2D

signal score_changed(amount)
signal pause_changed(state)

var tree: SceneTree
var places: Places # placeholders database
var viewport_size: Vector2
var score: int

onready var background: Node2D = find_node("Background")
onready var ground_layer: Node2D = find_node("GroundLayer")
onready var above_ground_layer: Node2D = find_node("AboveGroundLayer")
onready var ground: CanvasLayer = find_node("Ground") # canvas for ground viewport
onready var ground_viewport: Viewport = find_node("GroundViewport") # source of viewport texture
onready var ground_camera: Camera2D = find_node("GroundCamera") # main camera shadowing
onready var midair_layer: Node2D = find_node("MidairLayer")
onready var preview_layer: Node2D = find_node("PreviewLayer")
onready var path_follow: PathFollow2D = find_node("PathFollow")
onready var ground_texture: Sprite = find_node("GroundTexture")
onready var main_camera: Camera2D = find_node("MainCamera")
onready var player: PlayerBase = find_node("Player")
onready var information_layer: Node2D = find_node("InformationLayer")
onready var postprocess: BackBufferCopy = main_camera.find_node("Postprocess")
onready var hud: HUD = find_node("HUD")
onready var timer: Timer = find_node("Timer")


func _enter_tree() -> void:
#	print("Game entered tree") # TODO: remove this
	Global.game = self
	viewport_size = Global.viewport_size

	match Global.game_mode:
		Global.GAMEMODE.DEBUG:
			places = Preloader.get_resource("Places_demo").duplicate()
#			places = Preloader.get_resource("Places").duplicate()
		Global.GAMEMODE.DEMO:
			places = Preloader.get_resource("Places_demo").duplicate()

func _ready() -> void:
	tree = get_tree()
	var screen_rect = main_camera.find_node("ScreenRectShape")
	screen_rect.shape.extents = viewport_size / 2
	# next two properties must be set at runtime
	ground.custom_viewport = ground_viewport
	ground.follow_viewport_enable = true
	
	player.connect("destroyed", self, "_on_player_destroyed")
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

	# if start position is not zero, then all groups that can be placed on or behind the screen are truncated
	if path_follow.offset:
		var start_offset = path_follow.offset + viewport_size.y
		var size = places.groups.size()
		for index in size:
			var invert_index = size - index - 1
			if places.groups[invert_index].Offset > start_offset:
				places.groups.resize(invert_index)
				break
	
	pause(false)
		
	if Global.debug:
		Global.debug.init()

#func _notification(what: int) -> void: # TODO: remove this
#	if what == NOTIFICATION_PREDELETE:
#		print("Game is about delete")

func _process(delta: float) -> void:
	ground_camera.global_transform = main_camera.global_transform

func bump_camera() -> void:
	var shift = Vector2.ONE
	main_camera.offset += shift
	yield(tree.create_timer(0.05, false), "timeout")
	if main_camera.offset:
		main_camera.offset -= shift

func increase_score(value: int) -> void:
	score += value
	emit_signal("score_changed", value)

func pause(state: int = -1): # three state workaround: 0 - false, 1 - true, -1 - toggle
	var paused: bool
	if state == -1: # toggle by default
		paused = !tree.paused
	else:
		paused = state as bool # type casting
	
	if tree.paused != paused:
		tree.paused = paused
		emit_signal("pause_changed", paused)

func game_over() -> void:
	player.game_over()
	timer.stop()
	if hud.touch_controls:
		hud.touch_controls.visible = false
	hud.warnings.visible = false
	postprocess.visible = true
#	postprocess.update()
	
	Global.config.honor_points = score
	Global.config.save()
	hud.honor_points.text = "Honor points: %d" % score
	if score:
		for enemy_data in EnemyManager.ENEMIES:
			if enemy_data[EnemyManager.DESTROYED]:
				var stat_unit = Preloader.get_resource("StatisticUnit").instance()
				hud.statistic_units.add_child(stat_unit)
				stat_unit.init(enemy_data)
	
	var win = score >= Global.victory_value
	hud.gameover_caption.set("custom_colors/font_color", Color("70af69") if win else Color("bf4040"))
	hud.gameover_caption.text = "SUCCESS !\nKyiv is defended" if win else "FAILURE !\nKyiv is occupied"
	GlobalTween.game_over(win)
	
	yield(tree.create_timer(GlobalTween.GAMEOVER_DURATION, false), "timeout")
	var flag = hud.flag_ua if win else hud.flag_ru
	flag.visible = true
	hud.gameover_caption.visible = true
	hud.anthem.stream = Preloader.get_resource("Ukraine Anthem" if win else "Russia Anthem")
	hud.anthem.play()
	PoolManager.return_all_reusable()
	
	yield(tree.create_timer(GlobalTween.GAMEOVER_DURATION * 2, false), "timeout")
	hud.main_menu_button.visible = true

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
	else: # no more enemies - end of map TODO: replace with placemarkers
		timer.stop()
		yield(tree.create_timer(viewport_size.y * 2.5 / path_follow.scroll_speed, false), "timeout")
		game_over()
		return
	
	# back reusable objects behind
	var min_offset = offset - viewport_size.y * 2
	for node in tree.get_nodes_in_group(PoolManager.REUSABLE):
		if node.has_meta("Offset"):
			if node.get_meta("Offset") < min_offset:
				node.get_parent().remove_child(node) # back to an object pool

func _on_timer_timeout() -> void:
	_routine()

func _on_player_destroyed() -> void:
	game_over()
