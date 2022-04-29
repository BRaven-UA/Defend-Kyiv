class_name AAEnemy
extends Enemy

var player: PlayerBase
var position_3D: Vector3

onready var reload_timer: Timer = find_node("ReloadTimer")


func _ready() -> void:
	position_3D = Vector3(global_position.x, HEIGHT, global_position.y)
	reload_timer.connect("timeout", self, "_on_reload_timer_timeout")
	
	if Global.player: # attack only if player exists
		player = Global.player
		reload_timer.start()

func fire() -> void:
	if anti_aircraft in [EnemyManager.AA_ROCKETS, EnemyManager.AA_BOTH]:
		fire_rocket()

func fire_rocket() -> void:
#	var dir: Vector2 = Vector2.UP.rotated(global_rotation)
	var dest = player.global_position
	var dest3D = Vector3(dest.x, PlayerBase.HEIGHT, dest.y)
	var dir = (dest - global_position).normalized()
	var dir3D = Vector3(dir.x, 0.7, dir.y)
	
	var rocket: RocketBase = PoolManager.get_rocket()
	rocket.activate(self, position_3D, dir3D, player)

func _on_reload_timer_timeout() -> void:
	if not is_destroyed:
		fire()
