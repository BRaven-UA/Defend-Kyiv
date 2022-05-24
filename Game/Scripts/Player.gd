# main class for player entity
# contains only private fields and methods
extends PlayerBase

var analog_controller: AnalogController # touchscreen movement controller
var direction := Vector2.ZERO # current move normalized direction vector
var horizontal_limit: int # screen boundaries
var vertical_limit: int

var rocket_launchers: Array # list of the two available rocket launchers
var current_rocket_launcher_index: int # index of current launcher
var ready_to_fire: bool = true
var breakdown_threshold = MAX_HEALTH / 2
var is_breakdown: bool # engine failure

onready var shadow: Sprite = find_node("Shadow")
onready var smoke: Particles2D = find_node("Smoke")
onready var crossair: Sprite = find_node("Crossair")
onready var crossair_shadow: Sprite = find_node("CrossairShadow")
onready var highlight: Area2D = find_node("Highlight") # an area of highlighted vehicles with preview
onready var pusher: KinematicBody2D = find_node("BalloonPusher") # a physics body that pushes off preview balloons
onready var animation_tree: AnimationTree = find_node("AnimationTree") # blend space animation
onready var sound: AudioStreamPlayer2D = find_node("Sound")
onready var breakdown_sound: AudioStreamPlayer2D = find_node("Breakdown")
onready var empty_sound: AudioStreamPlayer2D = find_node("Empty")
onready var rocket_timer: Timer = find_node("RocketTimer")
onready var ammo_timer: Timer = find_node("AmmoReplenishTimer")


func _enter_tree() -> void:
	owner.player = self

func _ready() -> void:
	analog_controller = Global.analog_controller
#	call_deferred("emit_signal", "health_changed", health) # init the bar
	
	rocket_launchers.resize(2)
	rocket_launchers[0] = find_node("RocketLauncher1")
	rocket_launchers[1] = find_node("RocketLauncher2")
	rocket_timer.connect("timeout", self, "_on_RocketTimer_timeout")
	ammo_timer.connect("timeout", self, "_on_AmmoTimer_timeout")
#	connect()
	
	# calculating screen boundaries
	var player_extents = find_node("Hitbox").shape.extents # player boundaries
	horizontal_limit = Global.viewport_size.x / 2 - player_extents.x
	vertical_limit = Global.viewport_size.y / 2 - player_extents.y

func _process(delta: float) -> void:
	_moving(delta)
	
	# setting animation
	animation_tree.set("parameters/BlendTree/BlendSpace2D/blend_position", direction)
	animation_tree.set("parameters/BlendTree/TimeScale/scale", engine_efficiency)
	
	# moving the crossair, highlight area and preview pusher
	var _pos = (direction.reflect(Vector2.RIGHT) / 2 + Vector2.UP) * Vector2(CROSSAIR_DISTANCE * direction.y, CROSSAIR_DISTANCE) # Y-axis is inverted in 2D
	crossair.position = _pos
	highlight.position = _pos
	pusher.position = _pos
	var _spread_value = _pos.length() * RocketBase.SPREAD
	crossair.scale = Vector2.ONE * (_spread_value / 40.0) # default scale equal to 40 meters spread
	
	# adjust shadow position
	shadow.global_position = global_position + Global.SHADOW * 100
	crossair_shadow.position = Global.SHADOW.rotated(-crossair_shadow.global_rotation) * 7.0
	
	if Input.is_action_pressed("fire_rocket") and ready_to_fire:
		fire_rocket()
	
	sound.pitch_scale = engine_efficiency

func _moving(delta: float) -> void:
	# calculating user input vector
	var input_vector := Vector2.ZERO
	
	input_vector.x += Input.get_action_strength("ui_right")
	input_vector.x -= Input.get_action_strength("ui_left")
	input_vector.y += Input.get_action_strength("ui_up")
	input_vector.y -= Input.get_action_strength("ui_down")
	
	if analog_controller:
		input_vector += analog_controller.currentForce # combine with touch input
	
	var input_length = input_vector.length()
	if input_length > 1.0: # normalize ONLY oversized vector
		input_vector = input_vector.normalized()
	
	# direction vector adjustment based on user input
	var acceleration = delta * (FULL_ACCELERATION if Input.is_action_pressed("full_acceleration") else 1.0)
	
	if input_length < 0.1: # lesser than input's dead zone or no input at all
		# the move direction tends to zero
		direction = direction.move_toward(Vector2.ZERO, acceleration)
	else: # valid input values
		direction += input_vector.reflect(Vector2.RIGHT) * acceleration # Y-axis is inverted in 2D
		direction = direction.clamped(engine_efficiency)
	
	# move player
	var velocity_per_frame = direction * PLAYER_SPEED * acceleration
	velocity = velocity_per_frame / delta
	position += velocity_per_frame
	position.x = clamp(position.x, -horizontal_limit, horizontal_limit)
	position.y = clamp(position.y, -vertical_limit, vertical_limit)

func apply_damage(value: int) -> void:
	value *= damage_multiplier
	if value > 0:
		health = clamp(health - value, 0, MAX_HEALTH)
		emit_signal("health_changed", health)
		
		if health == 0:
			# TODO: rewrite for game over
			set_process(false)
#			Global.game.player = null
			return
		
		var is_badly_damaged = health < breakdown_threshold
		smoke.emitting = is_badly_damaged
		if is_badly_damaged:
			# low health visualization
			smoke.self_modulate.a = lerp(1.0, 0.0, health / MAX_HEALTH)
			
			if not is_breakdown:
				# random engine breakdown when taking damage
				var damage_level = MAX_HEALTH / health / 50.0
				if randf() < damage_level: # the more damage level, the more chances for breakdown
					is_breakdown = true
					breakdown_sound.play()
					GlobalTween.start_breakdown(self)
					var duration = breakdown_sound.stream.get_length() + randf() * damage_level * 10
					yield(get_tree().create_timer(duration), "timeout")
					is_breakdown = false
#					breakdown_sound.stop()
					GlobalTween.cancel_breakdown(self)

func fire_rocket() -> void:
	if rockets_amount:
		var launcher: RocketLauncher = rocket_launchers[current_rocket_launcher_index]
		
		var dir_3D_local = (Vector3(direction.x * direction.y, direction.y, abs(direction.y) - 2.0) * 0.5).normalized()
		var dir_3D_global = dir_3D_local.rotated(Vector3.UP, -global_rotation)
		var pos: Vector2 = launcher.global_position
		
		var target: Target = PoolManager.get_target()
		var target_position = crossair.global_position
		var spread = (target_position - pos).length() * RocketBase.SPREAD
		target.activate(target_position, spread)
		
		var rocket: RocketBase = PoolManager.get_rocket()
		rocket.activate(self, Vector3(pos.x, HEIGHT, pos.y), dir_3D_global, target)
		launcher.activate(Vector2(dir_3D_global.x, dir_3D_global.z))
		
		_change_rockets_amount(-rocket_consumption)
		current_rocket_launcher_index = current_rocket_launcher_index ^ 1 # swap 0 and 1
	else:
		empty_sound.play()
	
	ready_to_fire = false
	rocket_timer.start(ROCKET_COOLDOWN)

func _change_rockets_amount(value: int) -> void:
	var new_value = Global.clamp_int(rockets_amount + value, 0, MAX_ROCKETS)
	if new_value != rockets_amount:
		rockets_amount = new_value
		emit_signal("ammo_changed", rockets_amount)

func hit_by_rocket() -> void:
	apply_damage(10)
	GlobalTween.shake_camera()

func _on_RocketTimer_timeout() -> void:
	ready_to_fire = true

func _on_AmmoTimer_timeout() -> void:
	_change_rockets_amount(1)
