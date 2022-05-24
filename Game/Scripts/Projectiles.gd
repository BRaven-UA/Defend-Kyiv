class_name Projectiles
extends Particles2D

var time: float # travel time to the interception point
var fire_amount: int # amount of projectiles to fire
var hit_amount: int # amount of projectiles that hit the target
var target: Node2D
var interception_point: Vector3 # calculated point of interception
var hit_radius: float # how far projectiles can deviate from interception point
onready var timer: Timer = find_node("Timer") # one timer for all purposes (firing, travel, hitting)


func _ready() -> void:
	amount = EnemyManager.AA_CANNON_PARTICLES
	timer.connect("timeout", self, "_on_timer_timeout")

func _exit_tree() -> void:
	timer.stop()

# calculate interception point of the target and fire projectiles there
# return false in case target cannot be intercepted
func activate(pos: Vector3, tar: Node2D) -> bool:
	target = tar
	if tar == null or Global.game.midair_layer == null or Global.game.path_follow == null:
		return false
	
	var a = Vector3.ZERO # target 3D velocity
	if target is PlayerBase:
		var target_local_velocity = target.velocity
		var path_follow = Global.game.path_follow
		if path_follow:
			target_local_velocity += Vector2(0, -path_follow.scroll_speed) # added screen scrolling velocity
		var target_velocity_2D = target_local_velocity.rotated(target.global_rotation) # converting to global coords
		a = Vector3(target_velocity_2D.x, 0, target_velocity_2D.y)
	a.y = 0.1 # further calculations are valid for non-zero velocity
	
	var length_b = process_material.initial_velocity # projectile speed
	
	var target_pos_2D = target.global_position
	var target_pos_3D = Vector3(target_pos_2D.x, target.HEIGHT, target_pos_2D.y)
	var c = target_pos_3D - pos # 3D vector to target
	
	# for visual representation see 'Interseption drawing' picture at 'Temp' folder
	var angle_b = a.angle_to(-c)
	var _a = a.length() * sin(angle_b)
	if _a > length_b: # target can't be intercepted
		return false
	var angle_a = asin(_a / length_b)
	var angle_c = PI - angle_a - angle_b
	if angle_c < 0:
		return false
	
	var length_c1 = length_b * sin(angle_c) / sin(angle_b)
	var c1 = c.normalized() * length_c1
	var b = c1 + a # projectile velocity to the interception point
	
	time = c.length() / length_c1
	
	var final_vector = b * time # full 3D vector to the interception point
	interception_point = pos + final_vector # global coords
	var spread = process_material.spread * 3.0 # it's wider than visual spread for raelistic reason
	hit_radius = sin(deg2rad(spread)) * final_vector.length()

	Global.game.midair_layer.add_child(self)

	global_position = Vector2(pos.x, pos.z)
	global_rotation = -Vector2(b.x, b.z).angle_to(Vector2.UP)
	scale.y = Vector2(b.x, b.z).length() / length_b # it's workaround that allow keep particle material the same for all particles
	
	lifetime = time
	restart()
	fire_amount = amount
	_fire()
	
	return true

func deactivate() -> void:
	get_parent().remove_child(self)

# called when one projectile is fired
func _fire() -> void:
	var sound: AudioStreamPlayer2D = PoolManager.get_projectile_fire()
	Global.game.midair_layer.add_child(sound)
	sound.global_position = global_position
	sound.play()
	
	fire_amount -= 1
	if fire_amount > 0:
		var delay = 0.02 * randf()
		time -= delay
		timer.start(delay) # delay before next projectile
	else:
		timer.start(time) # all projectiles are fired, waiting until interception point

# called when projectiles reach the interception point
func _interception() -> void:
	var target_pos_3D = Vector3(target.global_position.x, target.HEIGHT, target.global_position.y)
	var distance_to_target = (target_pos_3D - interception_point).length()
	interception_point = Vector3.ZERO # interception point no longer relevant
	hit_amount = int(amount * (hit_radius - distance_to_target + 0.5) / hit_radius)
	
	if hit_amount > 0:
		_hit()
	else:
		deactivate()

# called when one projectile hit the target
func _hit() -> void:
	if target is PlayerBase:
		target.apply_damage(1)
		var sound: AudioStreamPlayer = PoolManager.get_projectile_hit()
		Global.game.midair_layer.add_child(sound)
		sound.play()
		Global.game.bump_camera()
	
	hit_amount -= 1
	if hit_amount > 0:
		var delay = hit_radius / 500.0 * randf()
		timer.start(delay) # delay before next projectile
	else:
		deactivate()

func _on_timer_timeout() -> void:
	if fire_amount:
		_fire()
	elif interception_point:
		_interception()
	elif hit_amount:
		_hit()
