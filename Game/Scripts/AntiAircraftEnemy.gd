class_name AAEnemy
extends Enemy

var player: PlayerBase
var position_3D: Vector3
var anti_aircraft: int # type of ant-aircraft system

onready var indicator: RadialIndicator
onready var rocket_reload_timer: Timer = find_node("RocketReloadTimer")
onready var cannon_reload_timer: Timer = find_node("CannonReloadTimer")


func _ready() -> void:
	rocket_reload_timer.connect("timeout", self, "_on_rocket_reload_timer_timeout")
	cannon_reload_timer.connect("timeout", self, "_on_cannon_reload_timer_timeout")
	
	indicator = Preloader.get_resource("RadialIndicator").instance()
	Global.game.information_layer.add_child(indicator, true)
	indicator.set_process(player != null)

func _exit_tree() -> void:
	_stop_fire()

func init(data: Dictionary, pos: Vector2, rot: float) -> void:
	.init(data, pos, rot)
	player = Global.game.player
	position_3D = Vector3(global_position.x, HEIGHT, global_position.y)
	
	anti_aircraft = data.get(EnemyManager.ANTIAIRCRAFT, EnemyManager.AA_NONE)
	var has_rockets: bool = anti_aircraft in [EnemyManager.AA_ROCKETS, EnemyManager.AA_BOTH]
	var has_cannon: bool = anti_aircraft in [EnemyManager.AA_CANNON, EnemyManager.AA_BOTH]
	
	indicator.call_deferred("activate", pos, has_cannon, has_rockets)
	
	if player: # attack only if player exists
		if has_rockets:
			rocket_reload_timer.start(1)
		if has_cannon:
#			cannon_reload_timer.start(1)
			set_collision_mask_bit(11, true) # screen rect detection

func fire_rocket() -> void:
#	if not is_destroyed:
	#	var dir: Vector2 = Vector2.UP.rotated(global_rotation)
		var dest = player.global_position
		var dest3D = Vector3(dest.x, PlayerBase.HEIGHT, dest.y)
		var dir = (dest - global_position).normalized()
		var dir3D = Vector3(dir.x, 0.7, dir.y)
		
		var rocket: RocketBase = PoolManager.get_rocket()
		rocket.activate(self, position_3D, dir3D, player)
		
		rocket_reload_timer.start(EnemyManager.AA_ROCKET_DELAY)
		indicator.start_outer_progress(EnemyManager.AA_ROCKET_DELAY)

func fire_cannon() -> void:
#	if not is_destroyed:
		var projectiles: Projectiles = PoolManager.get_projectiles()
		if projectiles.activate(position_3D, player):
			cannon_reload_timer.start(EnemyManager.AA_CANNON_DELAY)
			indicator.start_inner_progress(EnemyManager.AA_CANNON_DELAY)
		else: # failed to calculate deflection
			cannon_reload_timer.start(0.5) # wait a bit

func destroy() -> void:
	_stop_fire()
	indicator.deactivate()
	.destroy()

func _stop_fire() -> void:
	rocket_reload_timer.stop()
	cannon_reload_timer.stop()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "ScreenRect":
		cannon_reload_timer.start(EnemyManager.AA_CANNON_DELAY)
		indicator.start_inner_progress(EnemyManager.AA_CANNON_DELAY)
	else:
		._on_area_entered(area)

func _on_area_exited(area: Area2D) -> void:
	if area.name == "ScreenRect":
		cannon_reload_timer.stop()
	else:
		._on_area_exited(area)

func _on_rocket_reload_timer_timeout() -> void:
	fire_rocket()

func _on_cannon_reload_timer_timeout() -> void:
	fire_cannon()
